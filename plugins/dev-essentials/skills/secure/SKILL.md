---
name: secure
description: Security audit a codebase path — OWASP Top 10 (2025), secrets, dependency CVEs, misconfigs; write severity-ranked report to myreports/
argument-hint: <path> (optional, defaults to .)
---

**IMMEDIATE EXIT if path invalid:**
- If `$ARGUMENTS` is non-empty and the path does not exist: output "❌ Path not found: $ARGUMENTS" and STOP.

Target: `$ARGUMENTS` (default `.`)

1. Detect stack — check for `package.json`, `requirements.txt`, `go.mod`, `Gemfile`, `Cargo.toml`, `pom.xml`

2. Run available CLI scanners (skip silently if not installed):
   - **SAST:** `semgrep --config p/security-audit --config p/owasp-top-ten <target> --json 2>/dev/null`
   - **Secrets:** `gitleaks detect --source <target> --no-git 2>/dev/null`
   - **Python deps:** `pip-audit -r requirements.txt 2>/dev/null` (preferred over `safety`)
   - **Node deps:** `npm audit --json 2>/dev/null` (if package.json present)
   - **Deps (general):** `grype dir:<target> 2>/dev/null`

3. If no scanners available: use `grep` + `Read` for manual pattern matching
   - raise request to install proper tool to user.

4. Manual checks — always run regardless of scanner output, cite `file:line`:
   - **Secrets:** regex `(?i)(api[_-]?key|secret|password|token|private[_-]?key)\s*[=:]\s*['"][^'"]{8,}`; also scan `.env*` files
   - **Injection (OWASP A03):** unsanitised input reaching `exec`, `eval`, `query`, `system`, `subprocess`, `os.popen`, template literals in SQL
   - **Broken Access Control (OWASP A01/A10):** missing auth guards, path traversal `../`, SSRF (user-controlled URLs passed to HTTP clients), open redirects
   - **Auth failures (OWASP A07):** weak hashing (MD5/SHA1/DES), hardcoded credentials, missing JWT validation, no MFA enforcement
   - **Misconfig (OWASP A05):** `DEBUG=True`, open CORS (`*`), HTTP endpoints, world-readable secrets files, missing security headers (`X-Frame-Options`, `Content-Security-Policy`, `Strict-Transport-Security`)
   - **Exceptional conditions (OWASP A10 2025):** bare `except:` clauses, exception handlers that return success, swallowed errors

5. Allowed: up to 5 WebSearch queries for CVE lookups, library-specific known issues, or exploit pattern verification

6. Severity scale — Critical (RCE/auth bypass/exposed secrets) | High (injection/privesc) | Medium (misconfig/info leak) | Low (hardening gaps)

7. Determine label: basename of the resolved target path, with file extension stripped

8. `mkdir -p myreports` and create `myreports/.gitignore` (`*`) if it doesn't exist

9. Write report to `myreports/secure-<label>.md`:
   - Header: `# Security Audit: <target> — <YYYY-MM-DD>`
   - Summary line: `Critical: N | High: N | Medium: N | Low: N`
   - Findings sorted Critical → Low; format: `- [SEVERITY] file:line — description`
   - Sections: Secrets / Injection / Access Control / Auth / Misconfig / Dependencies / Exceptional Conditions
   - "None found" for clean sections

10. Output: "✅ Security report written to myreports/secure-<label>.md"
