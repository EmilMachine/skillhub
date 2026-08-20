---
name: nono
description: Stamp out a .nono folder (sandboxed Claude Code profiles for nono) into the current directory or a given path
argument-hint: [-f] [path]
allowed-tools: Bash(bash *nono.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/nono`. Do not trim or modify it.

- Run `bash "<BASE_DIR>/nono.sh" $ARGUMENTS`
- `-f` flag overwrites an existing `.nono`; without it, exits if one already exists
- Default target is the current working directory; pass a path to target elsewhere
- Report the files copied on success
- `README_nono.md` inside the copied folder has full setup/usage instructions (central profile install, run commands, troubleshooting)
