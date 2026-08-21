---
name: ruff
description: Format and lint-fix Python file(s) or directory via ruff format + ruff check --fix
argument-hint: <file_or_folder> (optional — defaults to current directory)
allowed-tools: Bash(bash *ruff.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/ruff`. Do not trim or modify it.

Run `bash "<BASE_DIR>/ruff.sh" $ARGUMENTS` (substitute the actual injected path) and print the output.
