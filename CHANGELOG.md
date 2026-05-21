# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | Versioning: [Semver](https://semver.org/)

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
