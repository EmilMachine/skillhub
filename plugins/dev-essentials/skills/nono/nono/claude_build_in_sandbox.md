# Claude Code built-in sandbox vs. nono

> As of Claude Code ~v2.1.229 / August 2026. Docs: https://code.claude.com/docs/en/sandboxing

---

## What the built-in sandbox does

Activated via `/sandbox` in a session or `sandbox.enabled: true` in settings.json.

**Scope:** Bash subprocesses only. Read/Edit/Write tools bypass it entirely and go through the permission system instead.

**Filesystem (default):**
- Write: CWD + session `$TMPDIR` only
- Read: entire host (credentials are readable unless explicitly denied)
- Protected: `.claude/` config, hooks, MCP files, shell startup files, git hooks/config

**Network:** no domains pre-allowed. First use of a new domain prompts; "Yes, and don't ask again" saves a `WebFetch(domain:...)` allow rule. Strict allowlist mode (`network.strictAllowlist: true`) blocks without prompting.

**OS enforcement:**
- macOS: Seatbelt (built-in, nothing to install)
- Linux/WSL2: bubblewrap + socat (must `apt install bubblewrap socat`)
- WSL1 / native Windows: not supported

---

## Key settings

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false,
    "autoAllowBashIfSandboxed": true,
    "filesystem": {
      "allowWrite": ["~/.kube"],
      "denyRead": ["~/"],
      "allowRead": ["."],
      "disabled": false
    },
    "network": {
      "allowedDomains": ["*.npmjs.org"],
      "strictAllowlist": true
    },
    "credentials": {
      "files": [
        { "path": "~/.aws/credentials", "mode": "deny" },
        { "path": "~/.ssh", "mode": "deny" }
      ],
      "envVars": [
        { "name": "GITHUB_TOKEN", "mode": "deny" }
      ]
    }
  }
}
```

**Settings precedence:** managed (MDM/server) > CLI `--settings` > `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.json`. Arrays (allowWrite, allowedDomains, etc.) are **merged** across scopes, not replaced.

**Two approval modes:**
- *auto-allow*: sandboxed Bash runs without prompt; non-sandboxable commands fall back to regular permission flow
- *regular permissions*: all Bash commands still prompt, even if sandboxed

**Escape hatch:** when a command fails sandbox restrictions, Claude may retry with `dangerouslyDisableSandbox: true` (disabled by setting `allowUnsandboxedCommands: false`).

**Credential masking** (v2.1.187+): `mode: "mask"` shows sandboxed commands a sentinel value; the built-in proxy swaps in the real credential on egress to listed hosts. Requires `network.tlsTerminate`. Supports `extract` regex, JWT decode, and AWS SigV4 re-signing.

**Known issue:** VS Code extension silently ignores sandbox settings — `/sandbox` slash command is unavailable there.

---

## nono comparison

| Dimension | Built-in `/sandbox` | nono |
|---|---|---|
| **Install** | zero — built into Claude Code | external: `brew install nolabs-ai/tap/nono` + profiles |
| **Scope** | Bash subprocesses only | wraps the whole `claude` process (Read/Edit/Write too) |
| **macOS engine** | Seatbelt | Seatbelt |
| **Linux engine** | bubblewrap | landlock |
| **Network default** | prompt per new domain | deny-all except explicitly listed (`claude.ai`, `api.anthropic.com`) |
| **Credential protection** | explicit opt-in via `credentials` block; nothing blocked by default | nothing blocked by default either; same weakness |
| **macOS Keychain** | works natively | cannot read Keychain — requires shell wrapper to extract to file |
| **Escape hatch** | `dangerouslyDisableSandbox` retry (disableable) | none — OS blocks it; no retry path |
| **Permission prompts** | has its own auto-allow mode | typically run with `--dangerously-skip-permissions` |
| **VS Code** | silently broken | works (wraps the process externally) |
| **Org enforcement** | managed settings, `failIfUnavailable` | no MDM hook; per-user profile install |
| **Credential masking** | yes — proxy substitution, SigV4, JWT | no |
| **Project-local config** | `.claude/settings.json` `sandbox.*` keys | `nono/local.jsonc` extending a base profile |

---

## Which to use

**Built-in sandbox** is the right default for:
- Teams on managed deployments (MDM enforcement, `failIfUnavailable`)
- Sessions that need credential masking / network TLS inspection
- VS Code users who can't use nono anyway (use `--settings` CLI flag as workaround)
- Any setup where you want sandbox + the normal Claude Code permission flow

**nono** is the right choice when:
- You want to sandbox Read/Edit/Write file tools too, not just Bash (built-in can't do this)
- You want deny-all network out of the box without configuring anything
- You run `--dangerously-skip-permissions` and want an external OS-level hard stop with no escape hatch
- You distrust the built-in escape hatch and want a harder boundary

**Combine both** for defense in depth: nono wraps the process (hard outer boundary), built-in sandbox handles Bash subprocess network filtering and credential masking inside.

---

## Limitations shared by both

- Workdir is fully readable — audit for secrets before running
- `~/.aws`, `~/.ssh`, credential env vars are not protected by default — must be explicitly denied
- Read/Edit/Write tools: built-in sandbox ignores them entirely; nono blocks at fs level but the grant still covers CWD
- Neither prevents an agent from writing secrets to CWD files and reading them back later
