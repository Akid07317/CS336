#!/usr/bin/env bash
set -euo pipefail
CS336_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || { echo 'Run inside WSL2 Ubuntu x86_64.' >&2; exit 1; }
[[ "$CS336_ROOT" != /mnt/* ]] || { echo 'Clone into ~/src/CS336 on the Linux filesystem.' >&2; exit 1; }
command -v nvidia-smi >/dev/null || export PATH="/usr/lib/wsl/lib:$PATH"
nvidia-smi || { echo 'Update the Windows NVIDIA driver and check wsl -l -v (version 2).' >&2; exit 1; }
sudo apt-get update
sudo apt-get install -y build-essential python3-dev git curl ca-certificates tmux pkg-config libomp-dev
if ! command -v uv >/dev/null; then
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT
    curl -LsSf https://astral.sh/uv/0.10.2/install.sh -o "$installer"
    sh "$installer"
    export PATH="$HOME/.local/bin:$PATH"
fi
if [[ $# -eq 0 ]]; then set -- a1 a2; fi
for assignment in "$@"; do
    "$CS336_ROOT/scripts/cs336" sync "$assignment"
    if [[ "$assignment" == a3 ]]; then
        "$CS336_ROOT/scripts/cs336" doctor "$assignment" --device cpu
    elif [[ "$assignment" == a2 ]]; then
        "$CS336_ROOT/scripts/cs336" doctor "$assignment" --device cuda --compile
    else
        "$CS336_ROOT/scripts/cs336" doctor "$assignment" --device cuda
    fi
done
echo 'Selected base environments verified. See docs/OMENMAX.md for A3 server / A5 GPU limitations.'
