---
name: skillhub-update
description: Update all installed plugins to latest — detects tool, diffs versions, updates stale
allowed-tools: Bash(bash *upgrade.sh*)
---

**Permission note:** To skip future prompts, add `"Bash(bash *upgrade.sh*)"` to `.claude/settings.json`.

**Claude Code:** The harness injects `Base directory for this skill: <path>` at the very top. That full path is `BASE_DIR` — it already ends in `.../skills/skillhub-update`. Do not trim or modify it. Run:
```
bash "<BASE_DIR>/upgrade.sh"
```

**Codex:** The plugin is installed under `~/.codex/plugins/cache/`. Find and run the latest copy:
```
bash "$(find "$HOME/.codex/plugins/cache" -name upgrade.sh -path "*/skillhub-update/*" 2>/dev/null | sort -V | tail -1)"
```

Stream all output directly to the user.
