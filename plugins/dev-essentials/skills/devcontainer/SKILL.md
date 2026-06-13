---
name: devcontainer
description: Stamp out a .devcontainer folder (claude-slim Docker setup) into the current directory or a given path
argument-hint: [-f] [path]
allowed-tools: Bash(bash *devcontainer.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the top — use that as `BASE_DIR`.

- Run `bash "<BASE_DIR>/devcontainer.sh" $ARGUMENTS`
- `-f` flag overwrites an existing `.devcontainer`; without it, exits if one already exists
- Default target is the current working directory; pass a path to target elsewhere
- Report the files copied on success
