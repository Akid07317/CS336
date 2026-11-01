"""Environment diagnostics only; independent of assignment implementations."""
import argparse
import importlib
import importlib.metadata
import json
import platform
import sys
from datetime import datetime, timezone
from pathlib import Path

MODULES = {
    "a1": ["cs336_basics", "einops", "einx", "numpy", "tiktoken", "wandb", "pytest"],
    "a2": ["cs336_systems", "cs336_basics", "numpy", "pandas", "matplotlib", "pytest"],
    "a3": ["cs336_scaling", "pydantic", "requests", "rich", "matplotlib", "pytest"],
    "a4": ["cs336_data", "numpy", "fasttext", "resiliparse", "fastwarc", "mmh3", "nltk", "pytest"],
    "a5": ["cs336_alignment", "accelerate", "transformers", "math_verify", "pylatexenc", "pytest"],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assignment", choices=MODULES, required=True)
    parser.add_argument("--device", choices=["auto", "cpu", "mps", "cuda"], default="cpu")
    parser.add_argument("--compile", action="store_true", help="Validate CUDA TorchInductor/Triton")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if sys.version_info[:2] != (3, 12):
        raise RuntimeError("Expected Python 3.12")
    report = {
        "checked_at": datetime.now(timezone.utc).isoformat(),
        "assignment": args.assignment,
        "python": platform.python_version(),
        "platform": platform.system() + " " + platform.machine(),
        "imports": [],
    }
    for module in MODULES[args.assignment]:
        importlib.import_module(module)
        report["imports"].append(module)
    if args.assignment != "a3":
        import torch

        device = args.device
        if device == "auto":
            device = "cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu"
        if device == "cuda" and not torch.cuda.is_available():
            raise RuntimeError("CUDA unavailable: check Windows NVIDIA driver, WSL2, and the selected environment")
        if device == "mps" and not torch.backends.mps.is_available():
            raise RuntimeError("MPS unavailable in this process")
        report.update(torch=torch.__version__, numpy=importlib.metadata.version("numpy"), device=device)
        if device == "cuda":
            properties = torch.cuda.get_device_properties(0)
            capability = torch.cuda.get_device_capability(0)
            report.update(gpu=properties.name, vram_gib=round(properties.total_memory / 2**30, 2),
                          capability=list(capability), cuda=torch.version.cuda, arch_list=torch.cuda.get_arch_list())
            if capability[0] >= 12 and tuple(map(int, torch.version.cuda.split(".")[:2])) < (12, 8):
                raise RuntimeError("Blackwell requires a CUDA 12.8+ PyTorch build")
        torch.manual_seed(336)
        x = torch.randn(32, 32, device=device, requires_grad=True)
        loss = (x @ x.T).square().mean()
        loss.backward()
        if not torch.isfinite(loss) or not torch.isfinite(x.grad).all():
            raise RuntimeError("Nonfinite result from matrix multiplication/backward")
        report["matmul_backward"] = "PASS"
        if device == "cuda":
            with torch.autocast("cuda", dtype=torch.bfloat16):
                mixed_loss = (x @ x.T).square().mean()
            mixed_loss.backward()
            torch.cuda.synchronize()
            if not torch.isfinite(mixed_loss) or not torch.isfinite(x.grad).all():
                raise RuntimeError("Nonfinite BF16 result")
            report["bf16_backward"] = "PASS"
        if args.compile:
            if device != "cuda":
                raise RuntimeError("--compile is intended for the OmenMax CUDA environment")
            import triton

            compiled = torch.compile(lambda value: value.sin() + 1, fullgraph=True)
            torch.testing.assert_close(compiled(x.detach()), x.detach().sin() + 1)
            torch.cuda.synchronize()
            report.update(triton=triton.__version__, torch_compile="PASS")
    elif args.device not in ("auto", "cpu") or args.compile:
        raise RuntimeError("a3 is the client/analysis environment; the optional JAX server is separate")
    report["status"] = "PASS"
    text = json.dumps(report, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
