# Plugin Verification Checklist

## Structure

```
<repo>/
├── .claude-plugin/marketplace.json
├── plugins/<name>/
│   ├── .claude-plugin/plugin.json
│   ├── .codex-plugin/plugin.json   # Codex compatibility (mirrors .claude-plugin/)
│   ├── README.md
│   └── skills/<skillname>/SKILL.md
├── CLAUDE.md
└── CHANGELOG.md
```

## Pre-Commit Checklist

**Marketplace:**
- [ ] `.claude-plugin/marketplace.json` valid JSON
- [ ] `metadata.version` follows semver
- [ ] All plugins in `plugins[]` array
- [ ] Versions match individual plugin.json
- [ ] CHANGELOG.md updated

**Plugin:**
- [ ] `.claude-plugin/plugin.json` exists (NOT root PLUGIN.json)
- [ ] `.codex-plugin/plugin.json` exists and mirrors `.claude-plugin/plugin.json`
- [ ] Fields: name, version, description, author{name,email}, skills[]
- [ ] Skills paths: `"./skills/<name>"` (directories, not .md files)
- [ ] `.opencode/skills/<skillname>` symlink exists for every skill in the plugin
- [ ] README.md: Skills, Workflow, Features, Installation

**Skill:**
- [ ] Path: `skills/<name>/SKILL.md` (capitalized)
- [ ] YAML frontmatter: `name`, `description`, `argument-hint` (if takes input), `allowed-tools` (if runs scripts)
- [ ] Early exit validation:
  ```markdown
  **IMMEDIATE EXIT if no argument:**
  - If `$ARGUMENTS` empty: output "❌ Error: ..." and STOP.
  ```
- [ ] Terse implementation (bullets, no fluff)
- [ ] Usage examples

## Local Testing

```bash
# Install
/plugin marketplace add <repo_path>
/plugin install <name>

# Verify
ls -la plugins/<name>/.claude-plugin/plugin.json
ls -la plugins/<name>/.codex-plugin/plugin.json
cat plugins/<name>/.claude-plugin/plugin.json | jq .
find plugins/<name>/skills -name "SKILL.md"

# Test
/<skillname> <args>

# Reload
/reload-plugins

# Reinstall
/plugin uninstall <name>
/plugin install <name>@<marketplace>
```

## Common Issues

**Skill not found:**
- Skills paths use directories: `"./skills/<name>"` not `"./skills/<name>.md"`
- SKILL.md capitalized
- YAML `name` matches invocation

**No argument validation:**
```markdown
**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` empty/missing: output "❌ Error: Required. Usage: /<cmd> <arg>" and STOP.
```

**Version mismatch:**
- Update marketplace.json AND plugin.json
- Run `/plugin marketplace update <name>`
- Reinstall plugin

**JSON errors:**
```bash
cat <file>.json | jq .  # Validates syntax
```

**Changes not reflected:**
```bash
/reload-plugins
# If still broken: uninstall + reinstall
```

**YAML not recognized:**
```yaml
---
name: skillname
description: Brief description
argument-hint: <param>   # optional — shown in slash-command autocomplete
---
```

**Supported frontmatter fields:**
| Field | Purpose |
|---|---|
| `name` | Skill invocation name |
| `description` | Shown in skill list |
| `argument-hint` | Usage hint in slash-command autocomplete (string, not list) |
| `allowed-tools` | Auto-approve specific tools; CSV, use patterns: `Bash(bash *script.sh*)` not bare `Bash` |
| `compatibility` | Runtime compatibility info |
| `disable-model-invocation` | Skip LLM call |
| `license` | License identifier |
| `metadata` | Free-form bag for external tooling; Claude Code does not parse sub-fields |
| `user-invocable` | Whether skill appears in slash menu |

**Do not use:** `args` or `arguments` — both are unsupported and silently ignored.

**Validator false positives:** The built-in SKILL.md linter only recognises Agent Skills open-standard fields and incorrectly flags Claude Code extended fields like `allowed-tools` as unsupported. This is a known bug ([#25380](https://github.com/anthropics/claude-code/issues/25380), [#27009](https://github.com/anthropics/claude-code/issues/27009)) — ignore those warnings.

## Version Updates

**Marketplace bump:**
```bash
# 1. Edit .claude-plugin/marketplace.json
{"metadata": {"version": "X.Y.Z"}}

# 2. Update CHANGELOG.md
## [X.Y.Z] - YYYY-MM-DD

# 3. Commit + tag
git commit -m "Bump to vX.Y.Z"
git tag vX.Y.Z
```

**Plugin bump:**
```bash
# 1. Update plugin.json
{"version": "X.Y.Z"}

# 2. Update marketplace.json plugins[] entry
{"name": "<name>", "version": "X.Y.Z"}

# 3. Update CHANGELOG.md
# 4. Commit
```

## New Plugin from Template

```bash
cp -r templates/plugin-template plugins/<name>

# Edit:
# - .claude-plugin/plugin.json (name, version, author, skills)
# - .codex-plugin/plugin.json  (copy of above for Codex compatibility)
# - skills/<skillname>/SKILL.md
# - README.md

# Add OpenCode symlink for each skill
ln -s ../../plugins/<name>/skills/<skillname> .opencode/skills/<skillname>

# Add to marketplace.json plugins[]

# Test
/plugin marketplace add <repo_path>
/plugin install <name>
```

## Best Practices

**SKILL.md:**
- ✅ YAML frontmatter
- ✅ Early exit validation
- ✅ Terse bullets
- ✅ Concrete examples
- ❌ No verbose paragraphs

**README.md:**
```markdown
# Plugin Name

Description.

## Skills

### `/<name>`
- **Input:** X
- **Output:** Y
- **Usage:** `/<name> <args>`

## Features

- Feature 1
- Feature 2

## Installation

/plugin install <name>@<marketplace>
```

**Semver:**
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

## Validation

```bash
# All JSON
find . -name "*.json" -exec sh -c 'cat {} | jq .' \;

# YAML frontmatter
find plugins -name "SKILL.md" -exec head -n 10 {} \;

# Skills paths
find plugins -name "plugin.json" -exec jq -r ".skills[]" {} \;

# Codex manifests present for every plugin
for d in plugins/*/; do
  [ -f "$d.claude-plugin/plugin.json" ] && [ ! -f "$d.codex-plugin/plugin.json" ] \
    && echo "MISSING .codex-plugin/plugin.json: $d"
done

# OpenCode .opencode/skills/ symlinks — every skill must have one
find plugins -name "plugin.json" -exec jq -r '.skills[]' {} \; | sed 's|^\./||' | while read skill_rel; do
  plugin_dir=$(dirname "$(find plugins -path "*/$skill_rel/../plugin.json" 2>/dev/null | head -1)")
  skill_name=$(basename "$skill_rel")
  [ ! -L ".opencode/skills/$skill_name" ] \
    && echo "MISSING .opencode/skills/$skill_name symlink"
done

# Structure
tree -L 4 plugins/
```
