# skillhub

Curated Claude Code plugins for personal development workflows.

## Installation

```bash
claude plugin add https://github.com/EmilMachine/skillhub
claude plugin install skillhub/example-plugin
claude plugin list
```

## Updates

```bash
# Update all
claude plugin update skillhub

# Check versions
cd ~/.claude/plugins/skillhub && git fetch && git log HEAD..origin/main --oneline

# Rollback if needed
cd ~/.claude/plugins/skillhub && git checkout HEAD~1
```

**Versioning**: MAJOR.MINOR.PATCH ([semver](https://semver.org/))
**Stay current**: Watch repo, check [CHANGELOG.md](./CHANGELOG.md), run updates monthly

## Plugins

### example-plugin
- `/hello` - Greeting skill demonstrating structure
- [Docs](./plugins/example-plugin/README.md)

## Creating Plugins

```bash
cp -r templates/plugin-template plugins/my-plugin
# Edit PLUGIN.json, skills/*.md, README.md
claude plugin add /path/to/skillhub  # test locally
```

**Structure:**
```
plugins/your-plugin/
├── README.md       # Required: usage + example
├── PLUGIN.json     # Required: metadata
└── skills/*.md     # Required: YAML frontmatter
```

**Requirements:**
- Must: README, PLUGIN.json, ≥1 SKILL.md with YAML
- Should: Prerequisites, semver
- Skip: Tests, complex processes

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Resources

- [CHANGELOG.md](./CHANGELOG.md)
- [Claude Code Docs](https://code.claude.com/docs)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Marketplace Docs](https://code.claude.com/docs/en/plugin-marketplaces)

## Contributing

Fork → Create plugin in `plugins/` → Add to `marketplace.json` → PR

---

**Maintainer**: Emil Machine ([@EmilMachine](https://github.com/EmilMachine))
**License**: MIT
