# skillhub for OpenCode

How to install skills for OpenCode

## Via .claude/skills (zero-config if using Claude Code too)

OpenCode also reads `.claude/skills/*/SKILL.md`. If you already have Claude Code skills installed, OpenCode picks them up automatically.

## Global Install (all projects - manual)

This repo ships `.opencode/skills/` with all skills pre-wired — clone once, then point your global or project config at it.


```bash
git clone https://github.com/EmilMachine/skillhub ~/.local/share/skillhub

# Symlink the whole skills bundle into your global opencode config
mkdir -p ~/.config/opencode/skills
for skill in ~/.local/share/skillhub/.opencode/skills/*; do
  ln -s "$skill" ~/.config/opencode/skills/
done
```

Skills are discovered on-demand — OpenCode sees available names and loads content when needed.

## Project-Local Install

```bash
# Run from your project root (repo must already be cloned as above)
mkdir -p .opencode/skills
for skill in ~/.local/share/skillhub/.opencode/skills/*; do
  ln -s "$skill" .opencode/skills/
done
```

Or selectively:

```bash
ln -s ~/.local/share/skillhub/.opencode/skills/mdresearch .opencode/skills/mdresearch
ln -s ~/.local/share/skillhub/.opencode/skills/mdplan     .opencode/skills/mdplan
```


## Update

```bash
cd ~/.local/share/skillhub && git pull
```

Symlinks are relative inside the repo, so a pull is all that's needed.

## Available Skills

| Skill | Plugin | Description |
|---|---|---|
| `mdresearch` | md3step | Research codebase from context file |
| `mdplan` | md3step | Generate implementation plan |
| `mdrefine` | md3step | Refine plan with inline answers |
| `mdimplement` | md3step | Execute plan with verification |
| `setup` | dev-essentials | Project setup |
| `codereview` | dev-essentials | Code review |
| `procon3` / `pc3` | dev-essentials | Pro/con analysis |
| `issue` | dev-essentials | Issue management |
| `cleanup` | dev-essentials | Cleanup analysis |
| `secure` | dev-essentials | Security review |

## Project Rules (AGENTS.md)

For lightweight integration without symlinking:

```bash
# Append a skill's instructions to your project rules
cat ~/.local/share/skillhub/plugins/md3step/skills/mdresearch/SKILL.md >> .opencode/AGENTS.md

# Or global rules
cat ~/.local/share/skillhub/plugins/md3step/skills/mdresearch/SKILL.md >> ~/.config/opencode/AGENTS.md
```

## Resources

- [OpenCode Skills docs](https://opencode.ai/docs/skills/)
- [OpenCode Agents docs](https://opencode.ai/docs/agents/)
- [OpenCode Config](https://opencode.ai/docs/config/)
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
