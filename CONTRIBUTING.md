# Contributing

## Setup & Use

**Install pre-commit hook (one-time, per clone):**
```bash
ln -sf "$(git rev-parse --show-toplevel)/scripts/pre-commit.sh" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Dependency:** `jq` — `brew install jq` if missing.

The hook validates `.claude-plugin` consistency and auto-syncs `.codex-plugin` and `.opencode/skills/` symlinks on every commit.

## Process

1. Fork → create plugin in `plugins/` → add to `.claude-plugin/marketplace.json` → PR

## Plugin Structure

```
plugins/your-plugin/
├── README.md
├── .claude-plugin/plugin.json
├── .codex-plugin/plugin.json      # mirror of .claude-plugin/plugin.json
└── skills/your-skill/
    └── SKILL.md
```

Add an `.opencode/skills/<skillname>` symlink for each skill:
```bash
ln -s ../../plugins/your-plugin/skills/your-skill .opencode/skills/your-skill
```

Full checklist: [AGENTS/plugin-verification.md](./AGENTS/plugin-verification.md)

## Marketplace Entry

`.claude-plugin/marketplace.json`:
```json
{ "name": "your-plugin", "source": "./plugins/your-plugin", "description": "...", "version": "1.0.0" }
```

## SKILL.md

YAML frontmatter + terse bullet instructions. Scripts are optional — see [AGENTS/scripts-use.md](./AGENTS/scripts-use.md).

## Testing

```bash
/plugin marketplace add /path/to/skillhub
/plugin install your-plugin
/reload-plugins
```

## PR Guidelines

- One plugin per PR
- Test locally first
- Note any dependencies

---

Owner merges directly. Community PRs merged when quality bar met.
