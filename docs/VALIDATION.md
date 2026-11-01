# 本机环境验收

日期：2026-11-01（Asia/Shanghai）。机器：MacBook Pro M1 Max，64GB 内存。

## 已完成

- uv 0.10.2，Python 3.12.13；五套环境各自安装、各自锁定依赖。
- a1/a2/a4/a5 使用 PyTorch 2.11.0；a1/a2/a5 的 NumPy 为 2.5.4，a4 为 1.26.4。
- 所有环境的安装完成；四套 Torch 环境以 `uv sync --offline --locked` 确认依赖齐全，a3 客户端安装完成。
- Mac 的项目构建使用现有 Command Line Tools；fastText 0.9.3 已成功编译并导入。
- 辅助 Python/Bash 语法、TOML/JSON 配置解析、锁文件相对路径和 Python 3.12 范围检查通过。
- 448 个官方跟踪文件在本机完整保留，与固定上游 commit 字节一致。186 个数据/权重等资产按忽略规则排除出 Git，恢复清单记录固定 URL 和 SHA256，并已逐一核对本机文件哈希。

| 环境 | 依赖导入 | CPU 矩阵计算与反向传播 | 官方测试收集 |
| --- | --- | --- | --- |
| a1 | PASS | PASS | 48 项 |
| a2 | PASS | PASS | 14 项 |
| a3 | PASS，客户端/绘图依赖 | 不适用 | 服务端测试不在客户端范围 |
| a4 | PASS，含 fastText/resiliparse/fastwarc | PASS | 21 项 |
| a5 | PASS，含 Transformers/Accelerate/math-verify | PASS | 26 项 |

A1 另外在真实 Apple GPU 上通过 MPS 矩阵计算与反向传播。运行时 JSON 回执位于本机 `artifacts/mac-*.json`，该目录不提交 Git。

测试收集共 109 项，没有执行未实现的作业测试，也没有把收集通过当作作业实现通过。A3 上游测试面向可选服务端；客户端环境中尝试收集会因缺少 FastAPI 失败，已明确排除于客户端验收，没有补装整套服务端或改动上游测试。

## 尚待训练机验收

OmenMax 当前已知为 Windows 11、尚未安装 WSL2。本次没有它的远程连接，未执行 Windows/Ubuntu 安装，也未测量其实际显存。

训练机需要按 `docs/OMENMAX.md` 完成首次安装，再保存 CUDA 回执。A1/A2/A4 的锁文件包含 Linux x86_64 / PyTorch 2.11.0+cu128 依赖，但这只是依赖解析结果，不是该 GPU 上的运行通过证据。

A3 自建 JAX 服务端、学生 API 权限、A5 完整 vLLM/FlashAttention GPU 栈、真实模型训练与多卡实验均未验收。A5 当前完成的是开发/测试基础环境。
