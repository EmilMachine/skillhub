# Codex Integration Notes

## Environment

- Detect Codex via `CODEX_THREAD_ID`, `CODEX_SANDBOX`, `CODEX_CI`, or `CODEX_MANAGED_BY_NPM` — NOT `CODEX_HOME`, `CODEX`, or `CODEX_SESSION_ID` (those are not set in Codex sessions)
- Codex bash subprocesses run inside a seatbelt sandbox (`CODEX_SANDBOX_NETWORK_DISABLED=1`) — no outbound network; marketplace installs/upgrades must be run from the terminal, not from inside Codex

## Marketplace

- Codex reads `.agents/plugins/marketplace.json` and `.claude-plugin/marketplace.json` — NOT `.codex-plugin/marketplace.json`
- `codex plugin marketplace add` is a terminal CLI command, not a Codex chat command
- With `--sparse .agents/plugins`, only that dir is checked out; marketplace.json entries must use `"source": "git-subdir"` so each plugin is fetched from GitHub individually on install

## Plugin Cache

- Plugin cache layout: `~/.codex/plugins/cache/<marketplace>/<plugin>/<version>/` — the directory name is the installed version
- To find a skill script without an injected base dir: `find "$HOME/.codex/plugins/cache" -name <script> -path "*/<skill>/*" 2>/dev/null | sort -V | tail -1`

## Skills

- Installed plugin skills are invoked as `$plugin-name:skill-name` (e.g. `$md3step:mdresearch`) — NOT `@skill-name`; the `@` prefix is for built-in Codex skills only
- Codex does NOT inject `Base directory for this skill: <path>` — that is a Claude Code harness feature; SKILL.md instructions must handle both cases explicitly
