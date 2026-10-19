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
