.devcontainer/Dockerfile_claude_slim_noweb
- Identical to the base image but adds iptables and gosu via apt
- Embeds /usr/local/bin/entrypoint-noweb.sh using Dockerfile 1.7 heredoc COPY <<'EOF'
- Ends USER root so the entrypoint runs as root, applies rules, then exec gosu devcontainer "$@" drops to non-root before the shell
starts
- Resolves all 4 domains from nono/claude-mac.jsonc at startup with getent ahostsv4

.devcontainer/devcontainer_noweb.json
- Same as devcontainer.json but adds --cap-add=NET_ADMIN to runArgs (needed for iptables in the entrypoint)
- remoteUser stays devcontainer — after gosu drops privileges, that non-root user has NET_ADMIN in the bounding set but not effective
set, so iptables commands from the terminal will be refused

One caveat to be aware of: NET_ADMIN must be in runArgs for the root entrypoint to call iptables, but once gosu execs as devcontainer,
that capability is not carried into the non-root process. --security-opt=no-new-privileges:true is kept since gosu drops (not gains)
privileges, so it's unaffected.

--- 
Clean. The Dockerfile now ends with USER devcontainer — same as the base image. Here's how the runtime flow works:

1. containerUser: root in devcontainer_noweb.json overrides the Dockerfile's USER devcontainer at runtime, so Docker starts the
container as root
2. Entrypoint runs as root — sets iptables, resolves and allowlists Anthropic IPs
3. exec gosu devcontainer "$@" — replaces the root process entirely; the VS Code server and every terminal session run as devcontainer
4. remoteUser: devcontainer — VS Code connects as devcontainer, which has no effective NET_ADMIN, so iptables commands from the
terminal are refused

The Dockerfile itself never has a USER root line after the entrypoint setup — it looks like a normal non-root image.