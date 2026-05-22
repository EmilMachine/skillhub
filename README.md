# skillhub

Curated Claude Code plugins for personal development workflows.

## Installation

### From Claude Code CLI (Inside Interactive Mode)

```sh
/plugin marketplace add https://github.com/EmilMachine/skillhub
/plugin install md3step
/plugin list
```

### Plugin Updates

**Note:** There is no direct `/plugin update <name>` command. To update an individual plugin, reinstall it:

**CLI:**
```sh
/plugin uninstall md3step
/plugin install md3step@skillhub
```

### Marketplace Updates

**CLI:**
```sh
/plugin marketplace update skillhub
/reload-plugins
```

### Local Development/Testing

```bash
# CLI: Add local marketplace
/plugin marketplace add /Users/your-username/code/skillhub
/plugin install md3step
```

**Versioning**: MAJOR.MINOR.PATCH ([semver](https://semver.org/))
**Stay current**: Watch repo, check [CHANGELOG.md](./CHANGELOG.md), run updates monthly

## Plugins

### md3step
Terse markdown research-plan-implement workflow.
- `/mdresearch <path>` - Research codebase from context file
- `/mdplan <path>` - Generate implementation plan from research
- `/mdrefine <path>` - Refine plan with user's inline answers
- `/mdimplement <path>` - Execute plan with testing and verification
- [Docs](./plugins/md3step/README.md)

### example-plugin
- `/hello` - Greeting skill demonstrating structure
- [Docs](./plugins/example-plugin/README.md)

## Creating Plugins

### Terminal

```bash
cp -r templates/plugin-template plugins/my-plugin
# Edit .claude-plugin/plugin.json, skills/*/SKILL.md, README.md

# Test locally
claude --plugin-dir /path/to/skillhub/plugins/my-plugin
```

### CLI

```
# Add local marketplace for testing
/plugin marketplace add /path/to/skillhub
/plugin install my-plugin
/reload-plugins
```

**Structure:**
```
plugins/your-plugin/
├── README.md                          # Required: usage + workflow
├── .claude-plugin/
│   └── plugin.json                    # Required: metadata
└── skills/
    └── skillname/
        └── SKILL.md                   # Required: YAML + implementation
```

**Requirements:**
- Must: README, .claude-plugin/plugin.json, ≥1 skill with SKILL.md
- Plugin.json: Use author object with name/email, skills array with paths
- Skills: YAML frontmatter, terse implementation instructions
- README: Skills section, Workflow, Features, Installation
- Should: Prerequisites, semver versioning
- Skip: Tests, complex processes

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Other Code Agents

For install and usage with other code agents see:
- [README_CODEX.md](./README_CODEX.md) — OpenAI Codex
- [README_OPENCODE.md](./README_OPENCODE.md) — OpenCode

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
