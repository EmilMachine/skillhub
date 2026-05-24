# Changelog Instructions

References: [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/) | [Semver](https://semver.org/)

## Format

```
## [MAJOR.MINOR.PATCH] - YYYY-MM-DD

**<Category>:**
- <terse description>
```

## Change Categories

- **Added** — new features
- **Changed** — changes to existing functionality
- **Deprecated** — soon-to-be removed
- **Removed** — removed features
- **Fixed** — bug fixes
- **Security** — vulnerability patches

## Versioning Rules (MAJOR.MINOR.PATCH)

- **MAJOR** — breaking / incompatible changes
- **MINOR** — new functionality, backward compatible
- **PATCH** — bug fixes, backward compatible
- Never modify a released version; always release a new one
- `0.y.z` = unstable/initial dev; `1.0.0` = first stable public API

## Rules

- Latest version first
- Use ISO 8601 dates (`YYYY-MM-DD`)
- Write for humans, not machines — no raw commit dumps
- Keep an `[Unreleased]` section while work is in progress
- Call out breaking changes, deprecations, and removals explicitly
