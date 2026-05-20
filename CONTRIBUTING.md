# Contributing

## Process

1. Fork repo
2. Create plugin in `plugins/`
3. Add to `.claude-plugin/marketplace.json`
4. Submit PR with brief description

## Requirements

**Must Have:**
- README.md (usage + example)
- PLUGIN.json (valid metadata)
- ≥1 SKILL.md (YAML frontmatter)

**Should Have:**
- Prerequisites/dependencies
- Semver version
- Multiple examples

**Skip:**
- Automated tests
- Multi-language docs

## Structure

Copy `templates/plugin-template/`:

```
plugins/your-plugin/
├── README.md
├── PLUGIN.json
└── skills/your-skill.md
```

## Add to Marketplace

Update `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-plugin",
  "source": "./plugins/your-plugin",
  "description": "Brief description",
  "version": "1.0.0"
}
```

## Testing

```bash
claude plugin add /path/to/skillhub
claude plugin list
# Test skill: /your-skill-name
```

## Best Practices

- Keep SKILL.md <500 lines
- Include concrete examples
- Test locally before PR

## PR Guidelines

- One plugin per PR
- Brief description
- Note dependencies

---

Owner commits directly. Community PRs merged when quality bar met.
