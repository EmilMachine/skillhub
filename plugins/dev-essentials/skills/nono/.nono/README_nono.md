# nono — sandboxed Claude Code

Runs Claude Code inside [nono](https://nono.sh)'s kernel-level sandbox (macOS Seatbelt / Linux landlock). Blast radius is limited to the working directory and the Anthropic API — no SSH keys, no browser data, no shell history, no arbitrary network.

- Main: https://nono.sh/ · git: https://github.com/nolabs-ai/nono · Blog: https://nono.sh/blog
- Comparison: https://eshlox.net/choosing-an-ai-sandbox
- Recipes: https://www.justinmklam.com/posts/2026/05/sandboxing-with-nono/

## 1. Install

**macOS**
```sh
brew install nolabs-ai/tap/nono
```

**Linux**
```sh
curl -fsSL https://nono.sh/install.sh | sh
```
Also packaged for Arch (`yay -S nono-ai-bin`) and Fedora/RHEL (rpm via the site).

## 2. Install the profile

Profiles live in `~/.config/nono/profiles/`. Copy the one for your OS from this folder:

```sh
# macOS
cp claude-mac.jsonc ~/.config/nono/profiles/claude-mac.json

# Linux
cp claude-linux.jsonc ~/.config/nono/profiles/claude-linux.json
```

- [`claude-mac.jsonc`](./claude-mac.jsonc) — includes macOS-only bits: Keychain-adjacent seatbelt rule, Launch Services (for opening URLs), `~/Library` read.
- [`claude-linux.jsonc`](./claude-linux.jsonc) — no keychain/seatbelt/Library entries; Linux stores Claude Code credentials in plain `~/.claude/.credentials.json`, already covered by the `~/.claude` grant.
- [`claude-mac-web.jsonc`](./claude-mac-web.jsonc) / [`claude-linux-web.jsonc`](./claude-linux-web.jsonc) — same local (filesystem/command) restrictions, unrestricted outbound network. See [§5](#5-web-variant--open-network).

`nono profile init <name> --extends base` scaffolds a fresh starting point if you'd rather build your own.

## 3. Run it

From any project directory, sandbox is scoped to that folder via `--allow-cwd`:

```sh
# macOS
nono run --profile claude-mac --allow-cwd -- claude --dangerously-skip-permissions

# Linux
nono run --profile claude-linux --allow-cwd -- claude --dangerously-skip-permissions
```

**One-time login gotcha (both OSes):** the sandbox usually can't open the OAuth callback port. Log in *outside* nono first:

```sh
claude   # log in once, plain, no nono
```

- **macOS:** creds land in Keychain, which the sandbox can't read directly — see the shell shortcut below, which extracts a token before each run.
- **Linux:** creds land straight in `~/.claude/.credentials.json`, which is already inside the `~/.claude` grant — no extra step needed, `nono-claude` just runs `claude` directly.

## 4. Shell shortcut

Add to `~/.bashrc` / `~/.zshrc`:

**macOS** — pulls the Keychain token into `~/.claude/.credentials.json` (sandbox can't read Keychain itself) then launches sandboxed:
```sh
nono-claude() {
  security find-generic-password -a "$USER" -s "Claude Code-credentials" -w \
    > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json \
    && nono run --profile claude-mac --allow-cwd -- claude --dangerously-skip-permissions "$@"
}
```

**Linux** — no credential extraction needed:
```sh
nono-claude() {
  nono run --profile claude-linux --allow-cwd -- claude --dangerously-skip-permissions "$@"
}
```

Reload (`source ~/.zshrc`), then just run:

```sh
nono-claude
```

## 5. Web variant — open network

`claude-mac.jsonc`/`claude-linux.jsonc` lock the network down to `claude.ai` + `api.anthropic.com`, so `WebSearch`/`WebFetch`, package installs, and arbitrary `curl` calls all fail. For sessions that need real internet access — but should still keep filesystem/command sandboxing — use the `-web` profiles instead:

```sh
# macOS
cp claude-mac-web.jsonc ~/.config/nono/profiles/claude-mac-web.json
nono run --profile claude-mac-web --allow-cwd -- claude --dangerously-skip-permissions

# Linux
cp claude-linux-web.jsonc ~/.config/nono/profiles/claude-linux-web.json
nono run --profile claude-linux-web --allow-cwd -- claude --dangerously-skip-permissions
```

These extend `base` (not `claude-mac`/`claude-linux`) — nono profile inheritance only ever *adds* to inherited lists, so a domain allowlist set by a parent can't be widened or cleared by a child. The web variants just never set one, which leaves network unrestricted (nono's default when no `allow_domain`/`network-profile` is applied).

> **Trade-off:** this removes the network egress guardrail. Filesystem/command restrictions are unchanged, but a prompt-injected or misbehaving agent can now reach any host, including exfiltrating whatever it can read locally. Default to the restricted profile; reach for `-web` only for the session that needs it.

## 6. Project-local profile (optional)

Only needed if one repo requires extra grants (e.g. an internal API domain). Skip otherwise — the central profile above covers normal use.

`./.nono/local.jsonc` in the repo:

```jsonc
{
  "extends": "claude-mac",  // or "claude-linux"
  "network": { "allow_domain": ["internal-api.example.com"] }
}
```

```sh
nono run --profile ./.nono/local.jsonc --allow-cwd -- claude --dangerously-skip-permissions
```

## 7. Shell shortcut for the local profile

Runs `./.nono/local.jsonc` from whatever repo you're in, instead of the central profile. Add alongside `nono-claude` (§4) in `~/.bashrc` / `~/.zshrc`:

**macOS**
```sh
nono-claude-local() {
  local profile="./.nono/local.jsonc"
  [[ -f "$profile" ]] || { echo "No $profile in $(pwd)"; return 1; }
  security find-generic-password -a "$USER" -s "Claude Code-credentials" -w \
    > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json \
    && nono run --profile "$profile" --allow-cwd -- claude --dangerously-skip-permissions "$@"
}
```

**Linux**
```sh
nono-claude-local() {
  local profile="./.nono/local.jsonc"
  [[ -f "$profile" ]] || { echo "No $profile in $(pwd)"; return 1; }
  nono run --profile "$profile" --allow-cwd -- claude --dangerously-skip-permissions "$@"
}
```

Reload, then run `nono-claude-local` from the repo root. Errors out with a clear message if that repo has no `.nono/local.jsonc` — use plain `nono-claude` there instead.

## 8. Multiple local directories

`--allow-cwd` only scopes to the directory you launched from. Two ways to reach other project dirs too:

**One-off (ad hoc, this run only):** `--allow <path>` is repeatable —
```sh
nono run --profile claude-mac --allow-cwd --allow ~/code/other-project --allow ~/code/shared-lib \
  -- claude --dangerously-skip-permissions
```

**Persistent (every run with this profile):** add the paths to `filesystem.allow` in the profile file, e.g. in `claude-mac.jsonc`:
```jsonc
"filesystem": {
  "allow": [
    "$HOME/.claude",
    "$HOME/code/other-project",   // add sibling projects here
    "$HOME/code/shared-lib"
  ],
  ...
}
```
Re-copy the edited file to `~/.config/nono/profiles/` (step 2) for the change to take effect. Prefer this over CLI flags if you always work across the same set of repos.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `OAuth error: Failed to start OAuth callback server` | Log in outside nono first (step 3), or add `"listen_port_range": [{"start":1024,"end":65535}]` under `network` to allow in-sandbox login (wider blast radius, localhost-only). |
| macOS: login works but `nono-claude` still can't authenticate | Keychain read failed — rerun the `security find-generic-password ...` line manually and check it prints a token. |
