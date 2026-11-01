#!/usr/bin/env bash
set -euo pipefail
CS336_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$(uname -s)" == Darwin && -z "${DEVELOPER_DIR:-}" && -d /Library/Developer/CommandLineTools ]]; then
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
fi
cd "$CS336_ROOT"
[[ $# -eq 1 ]] || { echo 'Usage: ./scripts/submit.sh "chore(env): describe change"' >&2; exit 2; }
branch="$(git branch --show-current)"
[[ -n "$branch" ]] || { echo 'Detached HEAD; select a branch first.' >&2; exit 1; }
git remote get-url origin
./scripts/cs336 doctor a1 --device cpu
./scripts/cs336 collect a1
git diff --check
git add -A
git diff --cached --check
git diff --cached --quiet && { echo 'No changes to submit.'; exit 0; }
git commit -m "$1"
git push -u origin "$branch"
