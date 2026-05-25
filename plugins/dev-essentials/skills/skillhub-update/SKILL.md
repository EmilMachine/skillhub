---
name: skillhub-update
description: Update all installed plugins to latest — detects tool, diffs versions, updates stale
allowed-tools: Bash(bash *upgrade.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` — use that path as `BASE_DIR`.

**Permission note:** Reads plugin state via Bash. To skip future prompts, add `"Bash(bash *upgrade.sh*)"` to `.claude/settings.json`.

**Step 1 — Detect tool + initial diff:**
Run `bash "<BASE_DIR>/upgrade.sh"` (substitute actual BASE_DIR).

Parse output lines (KEY=VALUE format):
- `TOOL=<tool>` — `claude` | `opencode` | `codex` | `unknown`
- `HINT=<msg>` — guidance when `TOOL != claude`
- `ERROR=<msg>` — fatal; print and STOP
- `PLUGIN=<k> INSTALLED=<v> AVAILABLE=<v> STATUS=<s> MARKETPLACE=<m>` — one per installed plugin

**Step 2 — Non-Claude path:**
If `TOOL != claude`: output the HINT line and STOP.

**Step 3 — Refresh catalogues:**
Collect unique MARKETPLACE values from PLUGIN lines.
For each unique marketplace: run `/plugin marketplace update <marketplace>`.

**Step 4 — Re-run diff (post-refresh):**
Run `bash "<BASE_DIR>/upgrade.sh"` again — parse PLUGIN lines for accurate STATUS.

**Step 5 — Show summary table:**
```
🔍 Plugin upgrade check  (Claude Code)
────────────────────────────────────────────────
  dev-essentials@skillhub   1.1.3 → 1.2.0   ⬆ outdated
  md3step@skillhub          1.0.1 = 1.0.1   ✅ up to date
────────────────────────────────────────────────
```
`AHEAD` means locally installed version is newer than marketplace (dev/local build) — treat as up to date.
If all `UP_TO_DATE` or `AHEAD`: output "✅ All plugins up to date." and STOP.

**Step 6 — Update stale plugins:**
For each `STATUS=OUTDATED` plugin:
- Run `/plugin update <name>@<marketplace>`
- On failure: try `/plugin uninstall <name>@<marketplace>` then `/plugin install <name>@<marketplace>`

**Step 7 — Reload:**
Run `/reload-plugins`

**Step 8 — Output:**
`✅ Upgraded <N> plugin(s) · reloaded.`
