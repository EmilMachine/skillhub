#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"

uv run --with ruff ruff format "$TARGET"
uv run --with ruff ruff check --fix "$TARGET"
