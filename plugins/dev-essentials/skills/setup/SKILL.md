---
name: setup
description: Bootstrap a project with agent config files and private prompt dirs
argument-hint: <project-root-path> (optional)
allowed-tools: Bash(bash *setup.sh*)
---

**Permission note:** This skill runs Bash to bootstrap project files. You may be prompted to allow Bash execution. To skip future prompts, add to `.claude/settings.json`: `"Bash(bash *setup.sh*)"`

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/setup`. Do not trim or modify it.

**IMMEDIATE EXIT if confirmation needed:**
- Runs setup.sh with optional `$ARGUMENTS` as root path
- Idempotent: skips files/dirs that already exist

1. Run `bash "<BASE_DIR>/setup.sh" $ARGUMENTS` via Bash tool (substitute the actual BASE_DIR path)
2. Report each created item (skip silently if already existed)
3. Remind user to fill in AGENTS.md with references to files in AGENTS folder.
