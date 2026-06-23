# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | Versioning: [Semver](https://semver.org/)

## [1.5.0] - 2026-06-23

**Changed:**
- dev-essentials v1.8.1:
  - `gitstats` skill: removed script-existence guard and error message from SKILL.md; now runs `bash "<BASE_DIR>/gitstats_all.sh"` directly
  - `gitstats` skill: simplified `allowed-tools` back to `Bash(bash *gitstats_all.sh*)` to match the direct invocation

**Plugins:**
- dev-essentials v1.8.1

---

## [1.4.9] - 2026-06-23

**Changed:**
- dev-essentials v1.8.0:
  - `gitstats` skill: replaced O(2N) per-author git calls in LINES/FILES/LAST mode with a single `git log --numstat` pass aggregated by awk — eliminates ~1900 sequential git invocations on large repos; runtime drops from minutes to seconds

**Plugins:**
- dev-essentials v1.8.0

---

## [1.4.8] - 2026-06-23

**Changed:**
- dev-essentials v1.7.9:
  - `gitstats` skill: removed bash 4+ dependencies from `gitstats_all.sh` — replaced `${arg^^}`/`${m,,}` with `tr` and `mapfile` with a `while read` loop; now compatible with macOS system bash (3.2)

**Plugins:**
- dev-essentials v1.7.9

---

## [1.4.7] - 2026-06-23

**Changed:**
- dev-essentials v1.7.8:
  - `gitstats` skill: collapsed two-step verify+run into a single Bash call (if/then/else inline), eliminating one permission prompt per invocation
  - `gitstats` skill: `allowed-tools` pattern tightened to `if [ -f "*gitstats_all.sh" ]; then bash "*gitstats_all.sh"*` — matches only the exact if/then structure the skill emits, not arbitrary commands referencing the filename

**Plugins:**
- dev-essentials v1.7.8

---

## [1.4.4] - 2026-06-22

**Changed:**
- dev-essentials v1.7.5:
  - `issue` skill: URL fallback now auto-opens browser via `open`/`xdg-open`; SKILL.md instructs Claude to repeat the URL as visible text if browser open fails
  - `issue` skill: added terse redaction audit step between field construction and script call
  - `issue/create_issue.sh`: `scrub()` now strips relative path segments (e.g. `org/repo`, `folder/subdir`) that aren't part of a URL, replacing with `basepath/subpath`
  - `learn` skill: always writes `AGENTS.md` and `AGENTS/` at git root; computes `SUBPATH` offset so reference links resolve correctly from monorepo root
  - `gitstats` skill: pre-flight `test -f` check on script path; exits with actionable error suggesting `/skillhub-update` if missing

**Plugins:**
- dev-essentials v1.7.5

---

## [1.4.3] - 2026-06-19

**Removed:**
- `.codex-plugin/marketplace.json` — Codex does not read this path; `.agents/plugins/marketplace.json` is the correct Codex marketplace location
- `scripts/pre-commit.sh`: removed Phase 2 that synced the now-deleted file; renumbered remaining phases

**Docs:**
- `AGENTS/plugin-verification.md`: replaced `.codex-plugin/marketplace.json` references with `.agents/plugins/marketplace.json`

---

## [1.4.2] - 2026-06-19

**Fixed:**
- dev-essentials v1.7.4: `upgrade-codex.sh` detects `CODEX_SANDBOX_NETWORK_DISABLED=1` before attempting marketplace refresh or remove/re-add; prints exact terminal commands to run instead of failing with a git network error

**Plugins:**
- dev-essentials v1.7.4

---

## [1.4.1] - 2026-06-19

**Fixed:**
- dev-essentials v1.7.3: `skillhub-update` SKILL.md now works in both Claude Code and Codex
  - Claude Code: continues using harness-injected `Base directory for this skill: <path>` as `BASE_DIR`
  - Codex: explicit `find` command against `~/.codex/plugins/cache/` to locate the latest installed `upgrade.sh`, avoiding stale symlinks under `~/.codex/skills/`

**Plugins:**
- dev-essentials v1.7.3

---

## [1.4.0] - 2026-06-19

**Added:**
- Codex marketplace now uses `git-subdir` sources in `.agents/plugins/marketplace.json` so `codex plugin marketplace add EmilMachine/skillhub --ref main --sparse .agents/plugins` works correctly — sparse checkout only needs `.agents/plugins/`, each plugin is fetched from GitHub on install
- `scripts/pre-commit.sh`: Phase 5 now generates `git-subdir` entries (deriving HTTPS URL from `git remote get-url origin`); falls back to `local` if no remote is configured
- `README_CODEX.md`: corrected all commands — removed hallucinated `$plugin-marketplace` syntax, replaced with actual `codex plugin marketplace add` / `codex plugin add --marketplace` CLI commands

**Fixed:**
- dev-essentials v1.7.2: `skillhub-update` Codex adapter
  - `upgrade.sh`: Codex detection now uses env vars actually injected by Codex (`CODEX_THREAD_ID`, `CODEX_SANDBOX`, `CODEX_CI`, `CODEX_MANAGED_BY_NPM`); old wrong vars removed
  - `upgrade-codex.sh`: rewrote upgrade logic to read installed plugins from `~/.codex/plugins/cache/<marketplace>/<plugin>/<version>/` instead of the marketplace sparse clone (which only contains `.agents/plugins/` and lacks plugin subdirs with git-subdir sources)

**Plugins:**
- dev-essentials v1.7.2

---

## [1.3.9] - 2026-06-16

**Changed:**
- dev-essentials v1.7.1: `/devcontainer` skill — added true color terminal setting to generated `devcontainer.json`

**Plugins:**
- dev-essentials v1.7.1

---

## [1.3.8] - 2026-06-16

**Changed:**
- md3step v1.2.0: minor polish to `mdplan` and `mdupdate`
  - `mdplan`: clearer `# Open Questions` instructions — explicit checkbox format (`- [ ] <question> — needed for: <step>`), scope limited to blockers/ambiguities, refine step now says to remove resolved questions after folding into steps
  - `mdupdate`: argument hint updated to reflect the skill works on research, plan, or any `.md` with inline `A:`/`Answer:` edits

**Plugins:**
- md3step v1.2.0

---

## [1.3.7] - 2026-06-13

**Added:**
- dev-essentials v1.7.0: `/devcontainer` skill — stamps out a `.devcontainer` folder (claude-slim Docker + Claude Code setup) into the current directory or a given path
  - Includes `devcontainer.json`, `Dockerfile_claude_slim`, and `devcontainer_README.md`
  - `-f` flag to force-overwrite an existing `.devcontainer`
  - Optional path argument; defaults to current working directory

**Plugins:**
- dev-essentials v1.7.0

---

## [1.3.6] - 2026-06-11

**Added:**
- dev-essentials v1.6.0: `/learn` skill — extract learnings from conversation history, a file, or freetext and save them to AGENTS.md / AGENTS/ files
  - History mode (no arg): reviews conversation context, proposes agent-relevant learnings
  - File mode: extracts learnings from a provided file path
  - Freetext mode: short directives added as direct rules; longer phrases used as history filter
  - Interactive confirm loop: Proceed / Modify / Stop before any writes
  - Routes learnings to existing AGENTS/ topic files or creates new ones with AGENTS.md reference

**Plugins:**
- dev-essentials v1.6.0

---

## [1.3.5] - 2026-06-11

**Changed:**
- dev-essentials v1.5.0: `/setup` skill simplified
  - Removed LOCAL_AGENTS.md and LOCAL_AGENTS.md.example scaffolding
  - Removed .gitignore mutation (no longer appends LOCAL_AGENTS.md entry)
  - CLAUDE.md now references only AGENTS.md (no LOCAL_AGENTS.md mention)
  - opencode.json instructions now only `["AGENTS.md"]`
  - All file creation fully idempotent (skip if exists, including CLAUDE.md)
  - AGENTS/ folder created empty

**Plugins:**
- dev-essentials v1.5.0

---

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
