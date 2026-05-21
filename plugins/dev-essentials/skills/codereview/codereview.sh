#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-}"
if [ -z "$BRANCH" ]; then
  echo "❌ Error: Branch name required. Usage: /codereview <branch>"
  exit 1
fi

mkdir -p mycodereviews

git fetch origin "$BRANCH" 2>/dev/null || {
  if [ -z "$(git branch --list "$BRANCH")" ]; then
    echo "❌ Branch not found locally or remotely. Run: git fetch origin $BRANCH"
    exit 1
  fi
}

DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||')
DEFAULT="${DEFAULT:-main}"

git diff "$DEFAULT".."$BRANCH"
