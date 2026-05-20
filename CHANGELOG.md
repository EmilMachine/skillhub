# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | Versioning: [Semver](https://semver.org/)

## [Unreleased]

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
