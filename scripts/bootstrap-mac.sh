#!/usr/bin/env bash
set -euo pipefail
CS336_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ "$(uname -s)" == Darwin ]] || { echo 'Run on macOS.' >&2; exit 1; }
command -v uv >/dev/null || { echo 'Install uv: brew install uv' >&2; exit 1; }
if [[ $# -eq 0 ]]; then set -- a1; fi
for assignment in "$@"; do
    "$CS336_ROOT/scripts/cs336" sync "$assignment"
    "$CS336_ROOT/scripts/cs336" doctor "$assignment" --device cpu
done
