---
name: ding
description: Install/update a Stop-hook sound notifier that dings when the agent finishes a turn, optionally only for turns longer than N seconds, with a choice of 5 bundled sounds
argument-hint: [local] [off|<seconds>[s]] [a|b|c|d|e]
allowed-tools: Bash(bash *ding-install.sh*), Bash(bash *ding-install-codex.sh*)
---

**Permission note:** This skill runs Bash to copy files and edit hook config files. You may be prompted to allow Bash execution. To skip future prompts, add to your settings: `"Bash(bash *ding-install.sh*)"` (Claude Code) or `"Bash(bash *ding-install-codex.sh*)"` (Codex).

- No args is a valid, meaningful invocation (global, always-ding) — do not treat empty `$ARGUMENTS` as an error.

**Claude Code:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/ding`. Do not trim or modify it. Run:
```
bash "<BASE_DIR>/ding-install.sh" $ARGUMENTS
```
Writes the hook into `settings.json`/`settings.local.json`. Report the scope/enabled/threshold summary the script prints, and the restart reminder — hooks only load at session start, so changes need a session restart to take effect.

**Codex:** The plugin is installed under `~/.codex/plugins/cache/`. Find and run the latest copy:
```
bash "$(find "$HOME/.codex/plugins/cache" -name ding-install-codex.sh 2>/dev/null | sort -V | tail -1)" $ARGUMENTS
```
Writes the hook into `hooks.json` (project-local `.codex/hooks.json` or global `~/.codex/hooks.json`) and enables `codex_hooks = true` under `[features]` in `~/.codex/config.toml` if not already set — Codex hooks are gated behind that flag. Report the same summary/restart reminder.

Stream all output directly to the user.

**Usage:**
- `/ding` — global, always ding
- `/ding local` — this project only (writes to gitignored `.claude/settings.local.json`), always ding
- `/ding off` — disable global (keeps the hook installed, just inert)
- `/ding local off` — disable local
- `/ding 60` or `/ding 60s` — global, only ding if the turn ran ≥60s
- `/ding local 80` — local, only ding if the turn ran ≥80s
- `/ding b` — global, switch sound to `b` (gong)
- `/ding local c 45s` — local, sound `c` (cardoor), only ding if the turn ran ≥45s

There is only ever one ding hook per scope — re-running `/ding`/`/ding local` with new args updates the existing one in place, never duplicates it.

**Sounds:** 5 bundled options, selected with a single letter token anywhere in the args (order-independent alongside `local`/`off`/`<seconds>`): `a` = ding, `b` = gong, `c` = cardoor, `d` = doorbell, `e` = magic. Omitting the letter keeps whatever sound was last configured for that scope (defaults to `a` on first install). The installed `config.jsonc` (next to the copied hook script) documents the current choices — to use a custom sound, get any short `.wav` file, save it alongside it as `<name>-<label>.wav`, then set `"sound"` to `<name>`.
