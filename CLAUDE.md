# Skillhub - Claude Code Plugin Marketplace

**Full validation:** [AGENTS/plugin-verification.md](./AGENTS/plugin-verification.md)

**Use of scripts in skills** [AGENTS/scripts-use.md](./AGENTS/scripts-use.md)

**Use of changelog** [AGENTS/changelog.md](./AGENTS/changelog.md)

## Structure

```
plugins/<name>/
├── .claude-plugin/plugin.json
├── README.md
└── skills/<skillname>/SKILL.md
```

## Code Conventions

**SKILL.md:**
- YAML frontmatter: `name`, `description`, optional `args`
- Start with "IMMEDIATE EXIT if no argument" validation
- Terse bullet-point instructions

**Commits:**
- Update CHANGELOG.md before version bumps
- Follow semver: MAJOR.MINOR.PATCH

## Pre-Commit

1. Validate all JSON
2. Check skill paths match directories
3. Test locally with `/reload-plugins`
4. Update versions (all locations)
5. Document in CHANGELOG.md

**Details:** [AGENTS/plugin-verification.md](./AGENTS/plugin-verification.md)
