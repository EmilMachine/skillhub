---
name: ding
description: Install/update a Stop-hook sound notifier that dings when Claude finishes a turn, optionally only for turns longer than N seconds
argument-hint: [local] [off|<seconds>[s]]
allowed-tools: Bash(bash *ding-install.sh*)
---

**Permission note:** This skill runs Bash to copy files and edit `settings.json`/`settings.local.json`. You may be prompted to allow Bash execution. To skip future prompts, add to `.claude/settings.json`: `"Bash(bash *ding-install.sh*)"`

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/ding`. Do not trim or modify it.

- No args is a valid, meaningful invocation (global, always-ding) — do not treat empty `$ARGUMENTS` as an error.
- Run `bash "<BASE_DIR>/ding-install.sh" $ARGUMENTS` (substitute the actual BASE_DIR path).
- Report the scope/enabled/threshold summary the script prints, and the restart reminder — hooks only load at Claude Code session start, so changes need a session restart to take effect.

**Usage:**
- `/ding` — global, always ding
- `/ding local` — this project only (writes to gitignored `.claude/settings.local.json`), always ding
- `/ding off` — disable global (keeps the hook installed, just inert)
- `/ding local off` — disable local
- `/ding 60` or `/ding 60s` — global, only ding if the turn ran ≥60s
- `/ding local 80` — local, only ding if the turn ran ≥80s

There is only ever one ding hook per scope — re-running `/ding`/`/ding local` with new args updates the existing one in place, never duplicates it.
