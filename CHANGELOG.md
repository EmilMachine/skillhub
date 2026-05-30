# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | Versioning: [Semver](https://semver.org/)

## [1.3.4] - 2026-05-30

**Changed:**
- dev-essentials v1.4.0: `skillhub-update` rewritten as modular script-only adapter architecture
  - `upgrade.sh` is now a pure dispatcher: detects tool, sources `lib.sh`, routes to the matching `upgrade-<tool>.sh` adapter
  - `lib.sh` — shared utilities: `_compare_versions`, `_print_table`, `_count_status`
  - `upgrade-claude.sh` — full Claude Code cycle: diff → marketplace refresh → re-diff → table → update → report; all via `claude plugin` Bash calls
  - `upgrade-codex.sh` — Codex adapter: tries `codex plugin update --all`, falls back to per-plugin update
  - `upgrade-opencode.sh` — OpenCode adapter: same pattern as Codex
  - Eliminates recursive sub-skill invocations that caused repeated permission prompts per iteration
  - Removes `/reload-plugins` (unknown command); replaced with explicit restart message
  - Adding support for a new tool = one new `upgrade-<tool>.sh` file, zero changes elsewhere
  - `SKILL.md` reduced to three lines: run script, stream output

**Plugins:**
- dev-essentials v1.4.0

---

## [1.3.3] - 2026-05-30

**Added:**
- dev-essentials v1.3.0: `/gitstats` skill — git contributor/file stats with three modes:
  - No arg / sort key (`LINES`/`FILES`/`LAST`) → all contributors ranked
  - Partial contributor name → top-10 files for that contributor
  - File path → contributor breakdown for that file

**Plugins:**
- dev-essentials v1.3.0

---

## [1.3.2] - 2026-05-26

**Added:**
- md3step v1.1.0: `mdplan` now scans sibling `*.md` files (excluding `2_plan.md`) as a fallback — triggered only if open questions remain after drafting the plan; answers are folded directly into the relevant plan steps, with only still-unresolved questions surfaced in `# Open Questions`

**Plugins:**
- md3step v1.1.0

---

## [1.3.1] - 2026-05-26

**Fixed:**
- dev-essentials v1.2.1: `codereview.sh` — switched from two-dot to three-dot diff (`git diff main...branch`), eliminating false "removal" findings for commits that landed on main after the branch was cut

**Plugins:**
- dev-essentials v1.2.1

---

## [1.3.0] - 2026-05-25

**Added:**
- dev-essentials v1.2.0: `/skillhub-update` skill — single command to update all installed plugins
  - Detects tool context via env vars (`CLAUDECODE`, `OPENCODE_*`, `CODEX_*`) with process-name fallback
  - Version diff: reads `installed_plugins.json` + marketplace cache to compare installed vs available
  - Refreshes all marketplaces, re-diffs, shows summary table, updates stale plugins, reloads
  - Handles non-Claude tools (OpenCode, Codex) with tool-specific guidance

**Fixed:**
- Added missing root-level `.codex-plugin/marketplace.json` (mirrors `.claude-plugin/marketplace.json` for Codex marketplace support)
- `marketplace.json` plugin version entries were stale — bumped `md3step` to `1.0.1`, `dev-essentials` to `1.2.0`
- `marketplace.json` metadata.version was `1.0.0` — synced to `1.3.0`
- Updated `AGENTS/plugin-verification.md` structure diagram and checklist to include `.codex-plugin/marketplace.json` and `.opencode/skills/`

**Changed:**
- `CONTRIBUTING.md`: added pre-commit hook install instructions (`scripts/pre-commit.sh`)

**Plugins:**
- dev-essentials v1.2.0

---

## [1.2.4] - 2026-05-24

**Fixed:**
- dev-essentials v1.1.3: `setup` — SKILL.md now uses harness-injected `BASE_DIR` for script path instead of fragile `$(dirname "")` which resolved to the wrong directory

**Changed:**
- Moved `.claude/plugin-verification.md` and `.claude/scripts-use.md` to `AGENTS/`
- Added `AGENTS/changelog.md` — terse Keep a Changelog + Semver reference for agents
- Updated all references in `CLAUDE.md` and `CONTRIBUTING.md`

**Plugins:**
- dev-essentials v1.1.3

---

## [1.2.3] - 2026-05-24

**Changed:**
- dev-essentials v1.1.2: `issue` — body passed via `ISSUE_TEXT` env var instead of stdin heredoc; always prints manual issue link via EXIT trap

**Plugins:**
- dev-essentials v1.1.2

---

## [1.2.2] - 2026-05-24

**Changed:**
- md3step v1.0.1: renamed `/mdrefine` → `/mdupdate`

**Plugins:**
- md3step v1.0.1

---

## [1.2.1] - 2026-05-22

**Fixed:**
- dev-essentials v1.1.1: `setup` — guard `.gitignore` append with explicit `if !` check and `printf` to prevent concatenation when file lacks trailing newline

**Plugins:**
- dev-essentials v1.1.1

---

## [1.2.0] - 2026-05-21

**Added:**
- dev-essentials v1.1.0: `issue` skill — two-phase: Claude populates fields from conversation context, Bash creates via gh/curl/prefill-URL; auto-labels `skillhub-bug`
- dev-essentials v1.1.0: `cleanup` skill — analyse path for dead code, unused tests, redundant logic, refactor opportunities, outdated docs; writes report to `myreports/cleanup-<label>.md`
- dev-essentials v1.1.0: `secure` skill — OWASP Top 10 (2025) security audit; runs semgrep/gitleaks/pip-audit/grype if available, falls back to grep patterns; severity-ranked report to `myreports/secure-<label>.md`

**Changed:**
- dev-essentials: renamed `mycodereviews/` → `myreports/` across setup.sh, codereview.sh, and SKILL.md
- dev-essentials: `/codereview` now writes to `myreports/codereview-<branch>.md`

**Plugins:**
- dev-essentials v1.1.0
- md3step v1.0.0
- example-plugin v1.0.0

---

## [1.1.0] - 2026-05-21

**Added:**
- dev-essentials v1.0.0 - Dev workflow essentials: project setup, code review, pro/con analysis
  - `/setup` - Bootstrap project with agent config files and private prompt dirs; idempotent
  - `/codereview <branch>` - Fetch branch diff and write terse major/minor/nit review to `mycodereviews/`
  - `/procon3 <topic>` - Find 3 alternatives with pros/cons inline; no file write
  - `/pc3 <topic>` - Alias for `/procon3`
  - Bash scripts handle all git/fs ops; Claude handles review/analysis

**Changed:**
- All skills: replaced unsupported `args:` list frontmatter with `argument-hint` string
- codereview, setup: added `allowed-tools: Bash(bash *<script>*)` for auto-approval
- `.claude/plugin-verification.md`: added frontmatter field reference table, validator false-positive note
- `.claude/scripts-use.md`: documented `allowed-tools` pattern syntax and caveats

**Plugins:**
- dev-essentials v1.0.0
- md3step v1.0.0
- example-plugin v1.0.0

## [1.0.0] - 2026-05-20

**Added:**
- md3step v1.0.0 - Terse markdown research-plan-implement workflow
  - `/mdresearch` - Research from context file
  - `/mdplan` - Generate implementation plan
  - `/mdrefine` - Integrate user edits into plan
  - `/mdimplement` - Execute with verification
- Plugin format: `.claude-plugin/plugin.json`, skills in subdirectories with `SKILL.md`
- Early exit validation for missing arguments
- "# Open Questions" section guidance (write last, place first)

**Changed:**
- example-plugin: Updated to match md3step format
- templates: Updated plugin-template structure
- README: Updated plugin creation docs, installation/update instructions

**Plugins:**
- md3step v1.0.0
- example-plugin v1.0.0

## [1.0.0] - 2026-05-20

**Added:**
- Marketplace structure (`.claude-plugin/marketplace.json`)
- Example plugin + template (`templates/plugin-template/`)
- README, CONTRIBUTING, update docs

**Plugins:**
- example-plugin v1.0.0

---

**Version format**: MAJOR.MINOR.PATCH
**Plugin updates**: See individual plugin README files
