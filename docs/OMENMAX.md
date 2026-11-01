# OmenMax：原生 Windows

默认路径 E:\MachineLearning\CS336。根 .venv 使用 Python 3.13 / Torch 2.10.0+cu130；WSL Ubuntu 不再是前置要求。

```powershell
cd E:\MachineLearning\CS336
.\scripts\cs336.ps1 doctor a1 --device cuda
.\scripts\cs336.ps1 collect a1
.\scripts\cs336.ps1 test a1 tests/test_tokenizer.py -q
```

首次安装执行 scripts/bootstrap-windows.ps1。日常同步先确认 git status，再 git pull --ff-only 和 scripts/cs336.ps1 sync a1。不要复制虚拟环境或强推另一台机器的修改。

根 uv.lock 是本机依赖依据；environments 下的锁文件是历史 Mac/Linux 方案。既有 cs336-lab 实验和 cs336-study 基础环境不作为本仓库启动依赖。

A2 Triton/分布式、A3 服务端、A4 数据工具链、A5 完整 GPU 栈需在开始对应作业时另做兼容配置。当前单卡诊断不代表这些环境全部可用。
