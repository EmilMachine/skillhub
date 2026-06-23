---
name: devcontainer
description: Stamp out a .devcontainer folder (claude-slim Docker setup) into the current directory or a given path
argument-hint: [-f] [path]
allowed-tools: Bash(bash *devcontainer.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/devcontainer`. Do not trim or modify it.

- Run `bash "<BASE_DIR>/devcontainer.sh" $ARGUMENTS`
- `-f` flag overwrites an existing `.devcontainer`; without it, exits if one already exists
- Default target is the current working directory; pass a path to target elsewhere
- Report the files copied on success
