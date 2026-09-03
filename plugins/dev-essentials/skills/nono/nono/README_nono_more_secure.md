# nono — security concerns and hardening options

These are optional steps beyond the baseline profiles. Each trades some convenience or compatibility for a smaller blast radius. Pick what fits your threat model.

---

## General concerns (all profiles)

### `/tmp` is a shared covert channel

Every profile allows full `/tmp`. A sandboxed agent can write data there as a staging area readable by any other local process — another agent run, a cron job, a second terminal — surviving the network block.

**Fix:** remove `/tmp` from the profile's `allow` list and pass a session-scoped directory via the CLI wrapper. Set `TMPDIR` so well-behaved tools follow it:

```sh
nono-codex() {
  local tmp=$(mktemp -d /tmp/nono-XXXXXX)
  TMPDIR="$tmp" nono run --profile codex-mac --allow-cwd \
    --allow "$tmp" \
    -- codex --sandbox danger-full-access "$@"
  rm -rf "$tmp"
}
```

Same pattern for Claude Code (`claude --dangerously-skip-permissions`), Linux profiles, etc. **Caveat:** tools that hardcode `/tmp` (ignoring `TMPDIR`) will get a permission denial — build toolchains, npm, and pip are generally fine.

### `$HOME/.cache` may contain credentials from other tools

All profiles grant full read-write to `$HOME/.cache`. This can include `$HOME/.cache/huggingface/token`, cached OAuth tokens from other CLIs, or sensitive build artifacts from unrelated projects.

**Fix:** enumerate specific subdirs:

```jsonc
"allow": [
  "$HOME/.cache/pip",
  "$HOME/.cache/npm",
  "$HOME/.cache/go/build",
  "$HOME/.cache/node"
]
```

Tradeoff: new tools silently fail to cache until you add their entry.

### `git_config` group exposes credential helpers

All profiles include the `git_config` group, which grants access to `~/.gitconfig` and associated credential helper binaries. Git credential helpers can vend tokens to `git` subprocesses — if the agent runs git commands, those helpers fire and their output is in-process.

**Concern:** a prompt-injected agent can call `git credential fill` and receive a GitHub/GitLab token even though `github.com` is blocked at the network layer. The token is now in memory and could be written to a workdir file.

**Fix options:** don't include `git_config` in profiles where git push/pull isn't needed, or configure a no-op credential helper for the sandboxed session via a wrapper that sets `GIT_CONFIG_NOSYSTEM=1` and `HOME` to a clean directory.

### API keys are passed verbatim into the sandbox

Codex profiles expose `OPENAI_API_KEY`; Claude profiles implicitly rely on `~/.claude` credentials. A key written to a workdir file or `/tmp` persists after the session ends.

**Fix for Codex (API key path):** create a restricted key in the OpenAI dashboard scoped to only `model.request` for the model Codex uses, with a spending limit. Use that key in the wrapper, not your primary key.

**Codex also supports a subscription / web login flow** (like Claude Code's OAuth) — credentials land in `~/.codex/auth.json`, already covered by the `~/.codex` grant. If you use this path instead of an API key, `OPENAI_API_KEY` can be dropped from `allow_vars` entirely, which is strictly better. The tradeoff is that the subscription flow requires browser-based auth: `allow_launch_services: true` on macOS (currently absent from the Codex mac profile) and `chatgpt.com` in the network allowlist (already present). Log in outside the sandbox first to avoid needing launch services at runtime, same as the Claude Code pattern.

**Fix for Claude Code:** Claude Code reads credentials from `~/.claude/.credentials.json` (Linux) or Keychain (macOS) rather than an env var, which is slightly better — but the credential file is fully readable inside the sandbox via the `~/.claude` grant. No easy workaround short of running a separate Claude account for sandboxed sessions.

### Workdir is fully readable

`workdir.access: readwrite` is intentional — it's why you run the agent — but it means any file in the project tree is in scope. If your project root contains `.env` files, secrets, or private keys checked in by mistake, the agent can read and potentially exfiltrate them (to workdir files, `/tmp`, or API call contents).

**Fix:** audit the workdir for secrets before sandboxed sessions. Use `.gitignore`-style tooling (`git-secrets`, `trufflehog`) as a pre-flight check. There is no profile-level mitigation for this.

---

## macOS-specific concerns

### `$HOME/Library` is very broad

`claude-mac.jsonc` and `codex-mac.jsonc` grant read access to all of `$HOME/Library`. macOS seatbelt can enforce deny-within-allow so the `default` profile's deny rules still apply, but the grant covers Mail, Safari history, SSH agent state, and more by default.

**Fix:** enumerate only the subdirs the runtimes actually need:

```jsonc
"read": [
  "$HOME/Library/Caches",
  "$HOME/Library/Application Support/npm",
  "$HOME/Library/Python"
]
```

Requires testing per runtime — the right set varies with what's installed.

### `allow_launch_services` lets the agent open apps and URLs

`claude-mac.jsonc` sets `allow_launch_services: true` (required for Claude Code's browser-based OAuth). This also lets the agent call `open https://...` or trigger any registered URL scheme — a prompt-injected agent could open a phishing URL in the user's browser, trigger a custom scheme handler, or interact with other apps.

**Concern:** there is no easy workaround while keeping OAuth working. Logging in outside the sandbox first (plain `claude` once) is the standard mitigation — the Keychain wrapper in `README_nono.md §5` is how the macOS shortcut handles it. If you do that, `allow_launch_services` is no longer needed for auth and could be dropped.

### `open_urls` and `listen_port_range` widen the surface beyond login

All `claude-*.jsonc` profiles now also carry `open_urls` (`allow_origins: ["https://claude.ai", "https://claude.com"]`, `allow_localhost: true`) so `claude login` can complete from inside the sandbox (see `README_nono.md §3`), and `claude-mac-web.jsonc` additionally carries `listen_port_range: [[30024, 40024]]` so the OAuth callback server can bind. Both are login-flow scaffolding — a normal coding session never needs to open a browser or accept an inbound connection.

**What's actually exposed while they're enabled:**
- `open_urls` (activated via `allow_launch_services` + the `--allow-launch-services` CLI flag) — the sandboxed process can ask macOS LaunchServices (or, on Linux, nono's parent-process delegate) to open any URL whose origin is `claude.ai` or `claude.com`. A prompt-injected agent doesn't need a *new* domain to abuse this — an attacker-controlled redirect or query string on either trusted origin is enough to pop a browser tab in front of the user mid-session.
- `listen_port_range` — the sandboxed process can bind ports in `30024–40024` and accept inbound connections. **On macOS this is broader than the range implies**: Seatbelt cannot filter listen/bind by port number, so once any listen capability is granted, the kernel permits binding *any* port — the declared range only exists to keep the expanded Seatbelt rule count under the ~16,384-port ceiling (the crash this profile was tuned around), not to narrow what's actually reachable. Anything else that can reach localhost — another sandboxed session, a webpage doing DNS rebinding, another local user — can talk to whatever the agent bound.

**Fix — disable both once you're logged in:**

```jsonc
// claude-mac-locked.jsonc
{
  "extends": "claude-mac",
  "open_urls": { "allow_origins": [], "allow_localhost": false },
  "allow_launch_services": false
}
```

```sh
nono run --profile claude-mac-locked --no-diagnostics --allow-cwd -- claude --dangerously-skip-permissions
```

`open_urls` and `allow_launch_services` both replace-on-override, so a child profile can clear them this way — confirm with `nono profile diff default claude-mac-locked`.

**`listen_port_range` can't be cleared the same way.** Profile list fields are additive across inheritance ("you can always *add* to a list, but you cannot remove something a base already includes"), so a profile that extends `claude-mac-web` keeps its inherited `listen_port_range` no matter what the child says. To actually drop it, either build the locked-down profile from `claude-mac`/`default` directly instead of `claude-mac-web` (re-adding whatever else the web variant provided), or keep `listen_port_range` out of `claude-mac-web.jsonc` in the first place and grant it only via a separate, dedicated login profile.

**Tradeoff:** with `open_urls` cleared and `listen_port_range` gone, `claude login` (re-authenticating, switching accounts, refreshing an expired session) fails outright — you have to switch back to the unlocked profile for that one command, then switch back afterward. Same login-outside-nono tradeoff as `README_nono.md §3`, just expressed as two profiles instead of two invocations.

### `unsafe_macos_seatbelt_rules` user-preference read is broad

Both mac profiles include `(allow user-preference-read)` to let macOS locale/timezone bootstrapping work. This covers all `NSUserDefaults` domains, not just locale — it includes any app preference plist the agent happens to know the domain name of.

**Concern:** low practical risk (preferences are rarely sensitive), but it is broader than strictly necessary. No easy targeted fix without knowing exactly which preference domains the runtimes read at startup.

---

## Linux-specific concerns

### Chrome browser data is granted read-write

`claude-linux.jsonc` and `claude-linux-web.jsonc` allow `$HOME/.config/google-chrome/` (read-write) and read `/opt/google/chrome/`. This is present to support browser-based flows (WebSearch via Chrome). It also means the agent can read Chrome's profile data — cookies, saved passwords stored in the `Login Data` SQLite file, browsing history.

**Fix:** if you don't use Chrome-based WebSearch in sandboxed sessions, remove both entries:

```jsonc
// remove from "read":
"/opt/google/chrome/"

// remove from "allow":
"$HOME/.config/google-chrome/"
```

The Codex Linux profile already omits these — Claude Linux profiles inherited them from early WebSearch support.

### `/proc` read access

`claude-linux.jsonc` and `claude-linux-web.jsonc` include `/proc` in `read`. This is required by some Node.js and Go runtime internals. It also lets the agent enumerate running processes (`/proc/*/cmdline`), read open file descriptors of other processes (`/proc/*/fd`), and inspect memory maps.

**Concern:** a determined agent could use `/proc` to discover what else is running on the host, find socket paths, or read environment variables of other processes (`/proc/*/environ`) if permissions allow. No straightforward fix — removing `/proc` breaks runtimes. Awareness item only.

---

## Network concerns (all profiles)

### `chatgpt.com` in Codex profiles is broader than the inference API

Codex profiles allow `chatgpt.com` alongside `api.openai.com` and `auth.openai.com`. This domain is required for the subscription / web login flow (analogous to `claude.ai` in the Claude profiles). If you exclusively use an API key and never use the web login path, `chatgpt.com` can be removed — inference and token refresh both go through `api.openai.com` and `auth.openai.com` only. If you use or might use the subscription login, keep it.

### Web variants remove the primary egress guardrail

`claude-mac-web.jsonc` / `claude-linux-web.jsonc` set `"network": { "block": false }` — fully open egress. Filesystem restrictions remain but any host is reachable.

**Fix:** prefer a narrow `allow_domain` in a project-local profile over the `-web` variants:

```jsonc
{
  "extends": "claude-mac",
  "network": { "allow_domain": ["pypi.org", "files.pythonhosted.org"] }
}
```

Reserve `-web` for sessions where you genuinely cannot enumerate the domains in advance.

---

## Summary table

| Concern | Profiles | Fix / mitigation |
|---|---|---|
| `/tmp` shared channel | all | Session-scoped dir via wrapper + `TMPDIR` |
| `$HOME/.cache` broad | all | Enumerate per-tool subdirs |
| `git_config` credential helpers | all | Drop group or use no-op helper wrapper |
| API key exposed verbatim | codex | Restricted + cost-limited key |
| Workdir contains secrets | all | Pre-flight secret scan; no profile fix |
| `$HOME/Library` broad | mac | Enumerate specific Library subdirs |
| `allow_launch_services` | `claude-mac` | Log in outside nono first, then drop |
| `open_urls` / `listen_port_range` left on permanently | `claude-*` | Split into login profile vs. locked-down profile pair |
| `(allow user-preference-read)` | mac | Awareness only; no targeted fix |
| Chrome data readable | linux claude | Drop chrome entries if not using browser WebSearch |
| `/proc` process enumeration | linux | Awareness only; removing breaks runtimes |
| `chatgpt.com` broader than API | codex | Try removing; test auth still works |
| `-web` profiles open egress | web variants | Use narrow `allow_domain` in local profile |
