#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-}"
if [ -z "$BRANCH" ]; then
  echo "❌ Error: Branch name required. Usage: /codereview <branch>"
  exit 1
fi

mkdir -p myreports
[ -f myreports/.gitignore ] || echo '*' > myreports/.gitignore

DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||' || true)
DEFAULT="${DEFAULT:-main}"

if git fetch origin "$BRANCH" 2>/dev/null; then
  BRANCH_REF="origin/$BRANCH"
elif git rev-parse --verify --quiet "refs/remotes/origin/$BRANCH" >/dev/null; then
  BRANCH_REF="origin/$BRANCH"
elif [ -n "$(git branch --list "$BRANCH")" ]; then
  BRANCH_REF="$BRANCH"
else
  echo "❌ Branch not found locally or remotely. Run: git fetch origin $BRANCH"
  exit 1
fi

git diff "origin/$DEFAULT"..."$BRANCH_REF"
