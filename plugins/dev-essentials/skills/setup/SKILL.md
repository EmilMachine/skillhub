---
name: setup
description: Bootstrap a project with agent config files and private prompt dirs
argument-hint: <project-root-path> (optional)
allowed-tools: Bash(bash *setup.sh*)
---

**IMMEDIATE EXIT if confirmation needed:**
- Runs setup.sh with optional `$ARGUMENTS` as root path
- Idempotent: skips files/dirs that already exist

1. Run `bash "$(dirname "$0")/setup.sh" $ARGUMENTS` via Bash tool
2. Report each created item (skip silently if already existed)
3. Remind user to fill in AGENTS.md and LOCAL_AGENTS.md placeholders
