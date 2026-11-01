# CS336：本机 Windows CUDA 自学仓库

以当前 OmenMax 为准：**Python 3.13.7、PyTorch 2.10.0+cu130、NumPy 2.3.5、RTX 5070 Ti Laptop GPU（12GB）**。默认直接使用 PowerShell，无需 WSL 或 Mac。

仓库：https://github.com/Akid07317/CS336 。官方作业固定为 Spring 2026，来源见 upstream-sources.json。本次只配置环境，没有实现作业答案。

## 开始 A1

在仓库根目录打开 PowerShell：

```powershell
.\scripts\cs336.ps1 doctor a1 --device cuda
.\scripts\cs336.ps1 collect a1
.\scripts\cs336.ps1 test a1 tests/test_nn_utils.py -q
```

先读 assignments/assignment1-basics/cs336_assignment1_basics.pdf，从 tokenizer 开始。作业尚未实现，功能测试出现 NotImplementedError 是预期的；诊断和收集成功不代表作业通过。

VS Code 默认解释器：.venv/Scripts/python.exe。运行自己的程序：

```powershell
.\scripts\cs336.ps1 run a1 python your_script.py
```

命令自动进入 A1 目录。不要在作业目录直接执行裸 uv run，它会读取官方的另一套环境约束。

## 安装和复现

新机器需要 Windows x64、Python + pip，以及适用的 NVIDIA Windows 驱动：

```powershell
.\scripts\bootstrap-windows.ps1
```

脚本在项目内安装 uv 0.13.6，用根 pyproject.toml 和 uv.lock 安装 Python 3.13 环境。已有环境同步：

```powershell
.\scripts\cs336.ps1 sync a1
```

缓存、环境、数据和运行产物留在本机，不提交 Git。W&B 默认 offline。普通 PyTorch 运算使用 wheel 自带 CUDA runtime，无需单独安装 CUDA Toolkit。

## 作业环境范围

| 作业 | 本机状态 |
| --- | --- |
| A1 | 默认环境，CPU/CUDA 诊断与官方测试收集；见验收记录 |
| A2 | 模板保留，Triton/编译/分布式尚未配置验收 |
| A3 | 模板保留，客户端与可选 JAX 服务尚未在本机安装 |
| A4 | 模板保留，fastText 等数据工具链尚未在本机安装 |
| A5 | 模板保留，vLLM/FlashAttention/RL 栈尚未配置 |

PowerShell 入口只接受 a1，避免把其他作业误导到同一套依赖。environments/a1–a5 和 Bash 脚本保留为旧 Mac/Linux 配置参考，不再是本机默认环境。

## Windows 适配

官方 A1 元数据要求 Torch 2.11 / NumPy >=2.4；根环境有意使用本机验证过的 Torch 2.10 / NumPy 2.3.5。官方源码和元数据保持原样，A1 从作业目录直接导入，没有强行安装存在依赖冲突的 editable 包。未来作业实现仍需逐项测试兼容性。

官方 tokenizer 测试无条件导入 Unix resource 模块。scripts/windows-pytest.py 仅允许导入，实际调用 resource API 会报错；两项内存限制测试按上游条件在 Windows 跳过。这不等于通过 Linux 内存限制测试。

恢复官方小型测试资产（固定 URL、SHA256 校验）：

```powershell
.\scripts\cs336.ps1 fixtures a1
```

此命令不下载完整训练集。训练语料、权重、密钥、缓存和输出不进 Git。12GB 显存下先做小规模实验，并记录代码 commit、随机种子、参数和指标。

验收见 [本机记录](docs/VALIDATION.md)，操作说明见 [OmenMax](docs/OMENMAX.md)。
