# OmenMax 2025 / RTX 5070 Ti 初次配置

目标：Windows 11 保留日常使用，WSL2 Ubuntu 24.04 承担 Linux/CUDA 训练。此文档和脚本已在 Mac 准备，尚未在训练机执行。首次配置需要你在 OmenMax 操作；目前没有它的远程连接。

## 1. Windows 驱动与 WSL2

安装适用于此机器的当前 NVIDIA Windows 显卡驱动，重启后在 PowerShell 中确认 `nvidia-smi` 可运行。[NVIDIA 官方驱动](https://www.nvidia.com/Download/index.aspx)

打开**管理员 PowerShell**：

```powershell
wsl --install -d Ubuntu-24.04
wsl --update
```

按提示重启，打开 Ubuntu 24.04，创建 Linux 用户名和密码。这是 Ubuntu 的本地账户，不是 GitHub 登录。回到 PowerShell 检查：

```powershell
wsl -l -v
```

`Ubuntu-24.04` 的 VERSION 应为 `2`。如不是：

```powershell
wsl --set-version Ubuntu-24.04 2
```

这是 [Microsoft 官方 WSL 安装流程](https://learn.microsoft.com/en-us/windows/wsl/install)。如果下载停在 0%，使用 `wsl --install --web-download -d Ubuntu-24.04`。

## 2. Ubuntu 登录 GitHub 并拉取仓库

以下命令全部在 **Ubuntu 终端** 执行：

```bash
sudo apt-get update
sudo apt-get install -y git gh curl ca-certificates
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
mkdir -p ~/src
cd ~/src
gh repo clone Akid07317/CS336
cd CS336
git switch main
bash scripts/bootstrap-omen.sh a1 a2
```

GitHub 设备登录会显示验证码和网站地址，在浏览器完成即可。仓库位于 Linux 的 `~/src/CS336`，请保留此位置，避免放在 `/mnt/c/`、OneDrive 或 Windows 桌面中。

脚本先验证 GPU 是否可见，再安装 Linux 编译工具、tmux 和 uv，创建 A1/A2 环境。PyTorch 使用 **2.11.0 + cu128**，A2 同时验证 Triton 和 `torch.compile`。首次运行下载 CUDA 库可能需要数 GB 磁盘与网络流量；不要在 Mac 复制 `.venv` 给训练机。

WSL 使用 Windows 的 NVIDIA 驱动。**不要在 Ubuntu 安装 `nvidia-driver-*`、`cuda-drivers` 或会带驱动的 `cuda` 总包。** PyTorch wheel 已带普通训练所需 CUDA runtime；只有编译 CUDA C++ 扩展时才另装与环境匹配的 toolkit-only 包。这一要求来自 [NVIDIA WSL 指南](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)。

## 3. CUDA 验收

```bash
./scripts/cs336 doctor a1 --device cuda --output "$PWD/artifacts/omen-a1.json"
./scripts/cs336 doctor a2 --device cuda --compile --output "$PWD/artifacts/omen-a2.json"
./scripts/cs336 fixtures a1
./scripts/cs336 collect a1
```

回执应显示真实 GPU 名称、显存、计算能力、Torch/CUDA 版本，以及矩阵计算、反向传播和 BF16 的 `PASS`。A2 还应有 `torch_compile: PASS`。这些才是此机基础训练环境已通过验收的证据。

如果 `nvidia-smi` 在 Windows 正常、Ubuntu 中失败，先检查 WSL VERSION、执行 Windows `wsl --update` 并更新 Windows 驱动。不要通过 Ubuntu 安装另一套驱动解决。Ubuntu 内 `nvidia-smi` 不在 PATH 时可运行 `/usr/lib/wsl/lib/nvidia-smi`。

## 4. 后续作业

安装 A3 客户端与 A4 数据环境：

```bash
bash scripts/bootstrap-omen.sh a3 a4
```

A4 NumPy 固定在 1.x，与 A1/A2 的 2.x 隔离。fastText 需要 Linux 编译器，安装脚本已包含。正式 A4 训练前，还需自行下载语料、完成数据作业，并按照手册判断缩小训练规模；官方的 8×B200 作业配置不能直接当作单卡配置运行。

A3 默认只安装客户端/绘图环境。2026 官方自建训练服务使用 `cs336-scaling[server]`、JAX CUDA 13 和额外服务/数据，未在此脚本默认启用。参考 `assignments/assignment3-scaling/README.md` 的非学生流程；需要运行服务端时另建环境，勿混装进 a1/a2。

A5 基础环境：

```bash
./scripts/cs336 sync a5
./scripts/cs336 doctor a5 --device cpu
./scripts/cs336 fixtures a5
./scripts/cs336 collect a5
```

本仓库的 a5 是开发/测试基础环境，**不是已验证的 vLLM GPU 训练栈**。官方 GPU extra 固定 `vllm==0.19.1`，还引用面向 Torch 2.10 的社区 FlashAttention wheel；不能在固定 Torch 2.11 的 a5 基础环境上直接追加安装并认为兼容。应在开始 A5 时另建 GPU 环境，核对 vLLM/Torch/CUDA/FlashAttention ABI、RTX 50 系列支持、目标模型显存，并运行实际推理/反向验收。当前机器上的完整 A5 GPU 可用性尚无证据。

## 5. 日常同步

Mac 提交后，在 OmenMax：

```bash
git status --short
git pull --ff-only
git rev-parse HEAD
./scripts/cs336 sync a1
tmux new -s cs336
```

在 tmux 中运行你编写的训练入口。`Ctrl+B` 后按 `D` 分离，`tmux attach -t cs336` 返回。将输出目录设在本机被忽略的 `artifacts/`、`runs/` 或 `checkpoints/` 中。

若在 OmenMax 修改代码，也必须先提交并推送，再在 Mac 拉取。不要让两台机器各自积累未提交修改后再互相覆盖；不要强推。GitHub 同步代码，不自动同步训练语料、权重或运行进程。

## 6. 可选远程使用

此阶段使用 GitHub 同步，无需对公网开放 SSH 端口。日后需要 Mac 远程操作时，可以再配置私网访问与 WSL SSH，验证新连接后启用 VS Code Remote SSH。当前未设置端口转发、远程账号或密钥。
