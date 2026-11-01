# 本机 Windows 环境验收

验收日期：2026-11-01（Asia/Shanghai）。本记录替代旧 Mac 验收作为当前默认；历史记录可从 Git 历史查看。

- 系统：Windows AMD64，Python 3.13.7。
- GPU：NVIDIA GeForce RTX 5070 Ti Laptop GPU，CUDA 可用显存总容量 11.94 GiB，计算能力 12.0。
- PyTorch 2.10.0+cu130，NumPy 2.3.5，uv 0.13.6。
- A1 所需模块导入通过；CPU / CUDA 矩阵运算及反向传播通过；CUDA BF16 反向传播通过。
- 官方 A1 测试收集 48 项通过；两项 Linux resource 内存限制测试实际执行结果为 skipped。
- 运行一个尚未实现的 softmax 测试，按预期在官方 adapters.py 抛出 NotImplementedError，退出码 1。没有修改答案或使未实现测试假通过。
- uv pip check：83 个包依赖一致。根环境直接导入 A1 源码，不安装要求 Torch 2.11 / NumPy >=2.4 的官方包元数据。
- 官方 A1 model.pt 测试资产通过固定 URL 下载和 SHA256 校验。
- 上游 assignments/ 跟踪文件无改动。

运行回执在本机 artifacts/windows-a1.json 和 artifacts/windows-a1-cpu.json。Codex 沙箱内 W&B 清理临时目录曾出现权限错误；在普通本机权限下重复 CPU/CUDA 检查均正常退出，无该清理错误。

这里只验收环境，不是作业实现通过。A2–A5 原生 Windows 环境、完整训练、Triton、分布式、JAX 服务、vLLM 和 FlashAttention 均未验收。旧 environments/ 及 Bash 脚本仅作为 Mac/Linux 参考。
- scripts/bootstrap-windows.ps1 已实际运行通过：项目内安装 uv、按锁同步依赖、CUDA 诊断成功。
