# nono + Colima isolated Docker daemon

> **macOS only.** Colima is a Lima-based VM wrapper that only runs on macOS. On Linux, Docker runs natively inside the same kernel — there is no VM boundary, no virtiofs, no host.docker.internal gateway problem. If you are on Linux or CI, use Docker-in-Docker instead (see `myservice/secure/BEST_SIMPLE_APPROACH.md`).

Runs Claude Code (or integration tests) in a nono sandbox backed by a dedicated Colima VM (`mysubnetwork`). Containers that escape the sandbox are contained inside the VM — they cannot read Mac files, reach Mac loopback services, or touch other Docker daemons on the Mac.

See `myservice/docs/colima_explained.md` for a full explanation of what each piece does and why.

---

## Files in this directory

| File | Purpose |
|---|---|
| `claude-mac-colima.jsonc` | nono profile for Claude Code with Colima socket |
| `colima-mysubnetwork.yaml` | Reference config for the VM (mounts + iptables provision) |
| `setup-colima.sh` | One-time VM setup script |
| `myservice/nono/test-colima.jsonc` | nono profile for running integration tests |

---

## One-time machine setup

### 1. Install Colima

```sh
brew install colima
```

### 2. Create the hardened VM

Run the setup script **once per machine** (or whenever you want to recreate the VM from scratch). It takes ~2 minutes the first time.

```sh
./nono/docker_mac_colima/setup-colima.sh
```

> `nono/docker_mac_colima/colima-mysubnetwork.yaml` is the reference config it applies — the script patches `~/.colima/mysubnetwork/colima.yaml` to match the `mounts` and `provision` fields defined there.

What it does:
- Deletes any existing `mysubnetwork` VM and creates a fresh one with `--network-address`
- Patches `~/.colima/mysubnetwork/colima.yaml` to:
  - Replace the default `$HOME` virtiofs mount with an empty scratch dir (`~/.colima-mounts/mysubnetwork`) — so containers cannot bind-mount real Mac files
  - Add an iptables provision script that blocks containers from reaching Mac loopback via `host.docker.internal`
- Restarts the VM with the patched config

### 3. Install the shared nono profile

```sh
mkdir -p ~/.config/nono/profiles
cp nono/docker_mac_colima/claude-mac-colima.jsonc ~/.config/nono/profiles/claude-mac-colima.jsonc
```

---

## Running Claude Code in the sandbox

Add to `~/.zshrc` / `~/.bashrc`:

```sh
nonodocker-claude() {
  # start VM if not running
  colima status mysubnetwork &>/dev/null \
    || colima start mysubnetwork

  # macOS: pull Keychain token into a file (sandbox can't read Keychain)
  security find-generic-password -a "$USER" -s "Claude Code-credentials" -w \
    > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json

  nono run --profile claude-mac-colima --no-diagnostics --allow-cwd \
    -- claude --dangerously-skip-permissions "$@"

  # stop the VM when claude exits (remove this line to keep it warm)
  colima stop mysubnetwork
}
```

Reload (`source ~/.zshrc`), then from any project:

```sh
nonodocker-claude
```

---

## Running integration tests in the sandbox

From `myservice/`:

```sh
./scripts/test-colima.sh
```

This starts the VM if not running, sets `DOCKER_HOST` + testcontainers env vars, runs pytest under `nono/test-colima.jsonc`, then stops the VM.

To run the escape/containment test suite:

```sh
./scripts/escapes-colima.sh
```

Expected result: 2/8 escaped (internet egress and `--privileged` — both VM-contained by design; see `colima_explained.md`).

---

## What is and isn't contained

| Attack surface | Status | How |
|---|---|---|
| Read Mac files via virtiofs bind-mount | Contained | Scratch dir replaces `$HOME` mount |
| Reach Mac loopback via `host.docker.internal` | Contained | iptables DROP on 192.168.5.1 + 192.168.5.2 |
| Reach other Docker daemons (OrbStack etc.) | Contained | Sockets absent in VM; virtiofs mount gone |
| Nested socket escape (`docker:cli` image) | Contained | Socket only exists inside VM scope |
| Container internet egress | **Not contained** | Required for `docker build` / image pulls |
| `--privileged` capabilities in VM | **Not contained** | VM-level blast radius only; Mac unaffected |

---

## Notes

- `colima stop` runs after Claude exits (normal or Ctrl-C). Remove it to keep the VM warm between sessions.
- First `colima start` downloads a VM image (~600 MB). Subsequent starts take ~3 s.
- Docker image layers are cached inside the VM. They are not shared with the host daemon (OrbStack etc.) — separate layer cache.
- If the VM gets into a bad state: `colima delete mysubnetwork --force && ./nono/docker_mac_colima/setup-colima.sh`
- Linux / CI: skip the `security` and `colima` lines — use DinD instead (see `myservice/secure/BEST_SIMPLE_APPROACH.md`).
