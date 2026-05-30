---
name: skillhub-update
description: Update all installed plugins to latest — detects tool, diffs versions, updates stale
allowed-tools: Bash(bash *upgrade.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` — use that path as `BASE_DIR`.

**Permission note:** To skip future prompts, add `"Bash(bash *upgrade.sh*)"` to `.claude/settings.json`.

Run `bash "<BASE_DIR>/upgrade.sh"` (substitute actual BASE_DIR) and stream the output directly to the user.
