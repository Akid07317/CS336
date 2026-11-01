# CS336：Mac 开发 → GitHub → OmenMax 训练

本仓库按 **Stanford CS336 Spring 2026** 配置。MacBook Pro M1 Max / 64GB 用于编码、CPU 单元测试和 MPS 小规模调试；OmenMax 2025 / RTX 5070 Ti 使用 **Windows 11 + WSL2 Ubuntu 24.04** 运行 CUDA。代码经私人 GitHub 仓库同步，两台机器各自安装环境。

私人仓库：<https://github.com/Akid07317/CS336>。

## Mac 直接开始

在仓库根目录运行：

```bash
./scripts/cs336 doctor a1 --device cpu
./scripts/cs336 doctor a1 --device mps
./scripts/cs336 collect a1
./scripts/cs336 test a1 tests/test_nn.py -q
```

作业尚未实现时，正式测试出现 `NotImplementedError` 是预期现象。`doctor` 检查环境；`collect` 只检查测试能否被发现；它们不代表作业完成。

所有命令都通过 `./scripts/cs336` 选择环境，并自动从对应作业目录运行：

```bash
./scripts/cs336 sync a2
./scripts/cs336 run a2 python your_script.py
./scripts/cs336 test a2 tests/test_attention.py -q
./scripts/cs336 fixtures a5
```

作业文件在 `assignments/`，每份模板的原始依赖、测试、许可、手册和课程说明均保留。环境定义在 `environments/a1` 至 `a5`，每份都有自己的 `.venv` 和 `uv.lock`。**不要合并五套环境，也不要直接在作业目录执行裸 `uv run`**，以免使用另一份环境和官方原始锁文件。

| 环境 | Python / PyTorch | Mac 用途 | OmenMax 用途 |
| --- | --- | --- | --- |
| a1 | 3.12 / 2.11.0 | CPU 测试、MPS 调试 | CUDA 12.8 训练 |
| a2 | 3.12 / 2.11.0 | 导入、CPU 可运行部分 | CUDA 12.8、Triton、性能实验 |
| a3 | 3.12 / 无 Torch | scaling 客户端、绘图 | 同样是客户端；JAX 训练服务另配 |
| a4 | 3.12 / 2.11.0 | 数据处理开发、NumPy 1.x | 数据处理、CUDA 12.8 小规模训练 |
| a5 | 3.12 / 2.11.0 | 基础依赖、CPU 测试开发 | 基础环境；完整 vLLM / FlashAttention 栈另配 |

A1/A2 使用 NumPy 2.x，A4 使用 NumPy 1.x。A2 保留官方随附的 `cs336-basics` 基线；没有替换成尚未完成的 A1。A3 没有默认安装大型 JAX 服务端。A5 没有启用官方 `gpu` extra，其 vLLM/Torch/FlashAttention 组合需要单独验证，不能混入 A1/A2 的环境。

A3 上游 `tests/` 面向可选服务端，包含 FastAPI/数据库/JAX 导入；它不属于此处的客户端环境验收。A3 用 `doctor a3` 检查，未安装服务端时不要运行 `collect a3` 或服务端测试。

VS Code 已推荐 Python、Pylance、Jupyter 扩展，默认解释器为 `environments/a1/.venv/bin/python`。切换作业时选择对应环境的解释器；不自动运行整套未完成的作业测试。

## 安装和复现

Mac 已有 Homebrew、uv 和 Python 3.12。重新安装选定环境：

```bash
bash scripts/bootstrap-mac.sh a1 a2 a3 a4 a5
```

依赖只写入项目 `.venv` 和 `.cache`；辅助脚本在 Mac 上优先使用已安装的 Command Line Tools，不修改全局 Xcode 选择。现有 uv 版本为 0.10.2；训练机安装脚本也固定此版本。`sync` 使用 `--locked`，依赖变化会显式失败，不会悄悄更新锁文件。

需要更新依赖时，编辑对应的 `environments/aN/pyproject.toml`，在根目录运行 `UV_CACHE_DIR="$PWD/.cache/uv" uv lock --project environments/aN`，再同步、验证，并提交锁文件。不要编辑官方作业的依赖文件来处理本机差异。

## 提交与训练

Mac 修改、验证后提交：

```bash
./scripts/cs336 test a1 tests/test_nn.py -q  # 选择本次已完成的功能
./scripts/submit.sh "feat(a1): describe your change"
```

提交脚本检查 A1 环境和测试收集、执行 `git diff --check`，然后提交并正常推送当前分支。它不会把“作业测试已全部通过”作为默认假设；提交功能前要自行运行对应测试。

OmenMax 拉取同一分支和提交后运行：

```bash
git pull --ff-only
git rev-parse HEAD
./scripts/cs336 sync a1
./scripts/cs336 doctor a1 --device cuda
./scripts/cs336 run a1 python your_training_script.py
```

训练脚本由学习过程中自行编写；本次只配置环境。长任务使用 `tmux new -s cs336`，`Ctrl+B` 后按 `D` 退出终端会话，`tmux attach -t cs336` 返回。电脑仍需接电，Windows 不应在训练时休眠。

首次配置 OmenMax 请按 [训练机安装步骤](docs/OMENMAX.md) 完成。

## 数据、权重与记录

Git 只同步代码、配置、锁文件和小型学习记录。训练语料、模型权重、缓存、日志、密钥不提交。保存实验时记录 Git commit、随机种子、配置、实际 GPU/显存、依赖版本和指标；大型产物另存，必要时手动传回 Mac。

官方模板中的少量权重和 A5 自带数据也被排除出 Git。`upstream-assets.json` 记录其固定上游 commit、路径、大小和 SHA256。需要时执行 `./scripts/cs336 fixtures a1` 或 `./scripts/cs336 fixtures a5` 还原；这不是下载 TinyStories/OpenWebText 全量训练集。A3 自带的 `data/isoflops_curves.json` 保留在 Git 中。下载正式训练语料时使用作业 README 中的官方地址，在训练机存储。

W&B 默认 `offline`，不需要登录即可开始。需要在线记录时，在本机 shell 设置 `WANDB_MODE=online` 并自行登录。`.env.example` 只列可选变量；辅助脚本不会自动执行 `.env`。

## 硬件和课程边界

单张 RTX 5070 Ti 适合 A1 和小规模实验。真实显存由 CUDA `doctor` 回执确认；不能把共享系统内存当作 CUDA 显存。缩小模型、上下文和 micro-batch 后的结果不等于官方全规模结果。多 GPU 通信、A4 官方 8×B200 训练，以及较大模型的完整 A5 RL 训练仍可能需要额外算力。

A3 2026 官方学生 API 使用学生凭据，外部学习者不能假定自己有权限；官方自建服务还涉及 JAX/CUDA、数据和服务组件。本仓库的 A3 客户端安装不等于获得 API 额度或部署好训练服务。A5 的完整 GPU 路线同样单独验收，具体见训练机文档。

## 来源与验证

上游仓库与固定 commit 见 `upstream-sources.json`。官方源文件保持原样，没有填写作业 TODO；环境封装在模板外。A1 上游 README 标题仍写 2025，但本次固定 commit 的项目版本为 26.0.0，与当前 2026 依赖一致。

本次本机验收结果见 [环境验收记录](docs/VALIDATION.md)。GPU 安装脚本不等于已在 OmenMax 执行验收。

参考：[课程官网](https://cs336.stanford.edu/)、[PyTorch 2.11 官方安装矩阵](https://pytorch.org/get-started/previous-versions/#v2-11-0)、[uv 依赖来源](https://docs.astral.sh/uv/concepts/projects/dependencies/)、[NVIDIA WSL 指南](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)。
