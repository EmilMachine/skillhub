# Dev Containers — Claude Slim

A dev container runs your tools (Python, uv, Claude Code) inside Docker while your code stays on the host. If something goes wrong inside, your machine is unaffected.

## Prerequisites
- Docker — installed and running
- Devcontainer-cli (see below)
- For **VS Code:** [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)


### Devcontainer-cli install
devcontainer cli installed (pinned to protect versus supply-chain attacks)
```sh
npm -g install @devcontainers/cli@0.87.0
```

Add to `~/.bashrc` or `~/.zshrc`:
```sh
# devcontainer-cli
export PATH="$HOME/node_modules/.bin:$PATH"
```

**optional**

Add quick shortcuts to your `~/.bashrc` or `~/.zshrc`:
```sh
dev-bash() {
    devcontainer up --workspace-folder . && \
    devcontainer exec --workspace-folder . bash
}

dev-claude() {
    devcontainer up --workspace-folder . && \
    devcontainer exec --workspace-folder . claude
}

dev-stop() {
    docker ps -q --filter "label=devcontainer.local_folder=$(pwd)" | xargs -r docker stop
}

dev-down() {
    docker ps -aq --filter "label=devcontainer.local_folder=$(pwd)" | xargs -r docker rm -f
}
```
Source or start a new terminal.

### project setup; 1. Place the devcontainer config in your project

### run and connect to the container

Spin up container:
```sh
devcontainer up --workspace-folder .
```

Start a session inside (exit with ctrl+D):
```sh
devcontainer exec --workspace-folder . bash
```

Or launch Claude Code directly:
```sh
devcontainer exec --workspace-folder . claude
```

### Close container
Stop (keeps container, fast restart next time):
```sh
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
```
Stop and remove (clean slate, devcontainer up rebuilds next time):
```sh
docker rm -f $(docker ps -aq --filter "label=devcontainer.local_folder=$(pwd)")
```

---

## B. VS Code

Then: `Cmd+Shift+P` → **Dev Containers: Reopen in Container**

VS Code builds the image (first time: a few minutes) and reopens with everything running inside.

### Rebuild after config changes

`Cmd+Shift+P` → **Dev Containers: Rebuild Container**

---

## Multi-repo mounts

Update mounts parts in devcontainer.json

```jsonc
"mounts": [
  // ...
  "type=bind,source=${localEnv:HOME}/<path>/other-repo,target=${localEnv:HOME}<path>/other-repo"
]
```

- Source path must exist on the host **before** the container starts
- Rebuild after changes: `Dev Containers: Rebuild Container`
