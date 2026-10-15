# nono + Docker-in-Docker isolated daemon

> **Linux / CI primary.** DinD runs a nested Docker daemon inside a container on the real host — no VM or brew required. Works on macOS too but the Colima approach (`nono/docker_mac_colima/`) is cleaner there. See `myservice/secure/BEST_SIMPLE_APPROACH.md #2` for background.

Runs Claude Code (or integration tests) in a nono sandbox backed by a throwaway `docker:dind` container (`mysubnetwork-dind`). Containers that escape the sandbox are contained inside the DinD container — they cannot read real host files, reach host loopback services, or touch other Docker daemons on the host.

---

## Files in this directory

| File | Purpose |
|---|---|
| `claude-linux-dind.jsonc` | nono profile for Claude Code with DinD socket |
| `start-dind.sh` | Start the DinD container (idempotent) |
| `stop-dind.sh` | Stop the DinD container and clean up |

---

## One-time machine setup

### 1. Pull the DinD image

```sh
docker pull docker:dind
```

### 2. Install profile and scripts to the central nono location

The scripts live alongside the profile they belong to — same install sweep:

```sh
mkdir -p ~/.config/nono/profiles
mkdir -p ~/.config/nono/docker_linux_dind

cp nono/docker_linux_dind/claude-linux-dind.jsonc ~/.config/nono/profiles/claude-linux-dind.jsonc
cp nono/docker_linux_dind/start-dind.sh           ~/.config/nono/docker_linux_dind/start-dind.sh
cp nono/docker_linux_dind/stop-dind.sh            ~/.config/nono/docker_linux_dind/stop-dind.sh
chmod +x ~/.config/nono/docker_linux_dind/*.sh
```

After this, nothing from the project repo is needed at runtime — the shell shortcut and CI scripts call `~/.config/nono/docker_linux_dind/` directly.

---

## Running Claude Code in the sandbox

Add to `~/.zshrc` / `~/.bashrc`:

```sh
nonodind-claude() {
  ~/.config/nono/docker_linux_dind/start-dind.sh

  DOCKER_HOST="unix:///tmp/mysubnetwork-dind/docker.sock" \
  nono run --profile claude-linux-dind --no-diagnostics --allow-cwd \
    -- claude --dangerously-skip-permissions "$@"

  ~/.config/nono/docker_linux_dind/stop-dind.sh
}
```

Reload (`source ~/.zshrc`), then from any project:

```sh
nonodind-claude
```

---

## Running integration tests in the sandbox

```sh
~/.config/nono/docker_linux_dind/start-dind.sh

DOCKER_HOST="unix:///tmp/mysubnetwork-dind/docker.sock" \
TESTCONTAINERS_RYUK_DISABLED=true \
TESTCONTAINERS_HOST_OVERRIDE="$(docker inspect mysubnetwork-dind --format '{{.NetworkSettings.Networks.mysubnetwork-dind-net.IPAddress}}')" \
nono run --profile claude-linux-dind --no-diagnostics --allow-cwd \
  -- .venv/bin/pytest tests/integration -v

~/.config/nono/docker_linux_dind/stop-dind.sh
```

> **`TESTCONTAINERS_HOST_OVERRIDE`:** With DinD, published ports are bound inside the DinD container, not on the real host. The test runner reaches them via the DinD container's IP on the `mysubnetwork-dind-net` bridge. The `docker inspect` call above resolves this IP at runtime. This differs from the Colima setup where Colima forwards published ports to `127.0.0.1`.

---

## What is and isn't contained

| Attack surface | Status | How |
|---|---|---|
| Read host files via bind-mount | Contained | Bind-mounts land inside the DinD container's filesystem |
| Reach host loopback via `host.docker.internal` | Contained | `host.docker.internal` resolves to the DinD container, not the real host |
| Reach other Docker daemons on the host | Contained | Only `/tmp/mysubnetwork-dind/docker.sock` is granted; real host socket absent |
| Nested socket mount | Contained | Socket scope is limited to the DinD daemon |
| `--privileged` capabilities | Contained | Root inside DinD container only, not on real host |
| Container internet egress | **Not contained** | DinD containers can reach the internet via host NAT |

---

## Notes

- The DinD container runs with `--privileged` on the **real host**. This is a one-time human-controlled step, not something the sandboxed agent can trigger. The agent only has the DinD socket.
- `--rm` on the DinD container means it auto-removes on stop; `stop-dind.sh` also cleans up the volume and network.
- Docker image layers are cached in the `mysubnetwork-dind-storage` volume. They persist across restarts until `stop-dind.sh` removes the volume.
- For CI, run `start-dind.sh` in a setup step and `stop-dind.sh` in teardown. The DinD container can stay up across multiple test runs.
- macOS: works, but `TESTCONTAINERS_HOST_OVERRIDE` must be the DinD container IP (not `127.0.0.1`), which makes it slightly more awkward than Colima. Use `nono/docker_mac_colima/` on Mac instead.
