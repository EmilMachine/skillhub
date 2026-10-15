#!/usr/bin/env bash
# One-time setup: create (or recreate) the mysubnetwork Colima profile
# with restricted Lima mounts so containers cannot access real Mac files
# via Lima's virtiofs.
#
# Run this once per machine before using test-colima.sh or escapes-colima.sh.
# It DELETES any existing mysubnetwork instance (losing cached images).
#
#   ./scripts/setup-colima.sh
#
# What it does:
#   --network-address  gives the VM its own IP and enables host.docker.internal routing
#   mounts:            overrides the default $HOME mount with a dedicated scratch dir,
#                      so containers cannot bind-mount real Mac files via virtiofs
set -euo pipefail

PROFILE="mysubnetwork"
SCRATCH_DIR="$HOME/.colima-mounts/$PROFILE"
COLIMA_PROFILE_DIR="$HOME/.colima/$PROFILE"

if colima status "$PROFILE" &>/dev/null; then
  echo "Stopping existing '$PROFILE'..."
  colima stop "$PROFILE" || true
fi

if colima list 2>/dev/null | grep -q "^$PROFILE"; then
  echo "Deleting existing '$PROFILE' (cached images will be lost)..."
  colima delete "$PROFILE" --force
fi

# Ensure scratch dir exists — Lima validates that mount paths exist on the host
mkdir -p "$SCRATCH_DIR"

echo "Creating '$PROFILE' with restricted mounts..."
colima start "$PROFILE" --network-address

# Patch the generated colima.yaml to replace the default $HOME mount
# with the scratch dir before the VM fully provisions.
# (colima start with no --mount creates $HOME mount by default; we override it here)
colima stop "$PROFILE" 2>/dev/null || true

COLIMA_YAML="$COLIMA_PROFILE_DIR/colima.yaml"
if [[ -f "$COLIMA_YAML" ]]; then
  python3 - "$COLIMA_YAML" "$SCRATCH_DIR" <<'PYEOF'
import sys, re

path, scratch = sys.argv[1], sys.argv[2]
with open(path) as f:
    text = f.read()

# 1. Replace mounts block with scratch dir only (prevents Lima virtiofs from
#    exposing $HOME to containers).
# Handles both single-line `mounts: []` and multi-line blocks.
text = re.sub(
    r'^mounts:[^\n]*(?:\n(?:[ \t].+))*',
    f'mounts:\n  - location: {scratch}\n    writable: true',
    text,
    flags=re.MULTILINE
)

# 2. Replace provision: null with an iptables rule that blocks containers from
#    reaching the Mac host via host.docker.internal.
#    The Colima gateway (192.168.5.1) is the Mac's IP on the VM's subnet —
#    host.docker.internal resolves to this address. Blocking it closes escapes
#    04 and colima_network_to_mac without touching internet egress (pip install
#    during docker builds, image pulls) or published-port connections.
#
#    Escape 01 (internet egress via containers) remains possible at the VM level —
#    containers can reach the public internet through the VM's NAT — but this is
#    VM-contained blast radius, not the Mac host directly.
iptables_provision = '''provision:
  - mode: system
    script: |
      for i in $(seq 1 60); do
        iptables -L DOCKER-USER >/dev/null 2>&1 && break
        sleep 1
      done
      iptables -D DOCKER-USER -d 192.168.5.1 -j DROP 2>/dev/null || true
      iptables -I DOCKER-USER 1 -d 192.168.5.1 -j DROP
      iptables -D DOCKER-USER -d 192.168.5.2 -j DROP 2>/dev/null || true
      iptables -I DOCKER-USER 1 -d 192.168.5.2 -j DROP'''

text = text.replace('provision: null', iptables_provision)

with open(path, 'w') as f:
    f.write(text)
print(f"Set mounts to: {scratch}")
print("Added iptables provision (blocks container egress, allows published ports)")
PYEOF
fi

echo "Starting '$PROFILE' with patched config..."
colima start "$PROFILE"

echo
echo "✓ '$PROFILE' ready."
echo "  Socket:  \$HOME/.colima/$PROFILE/docker.sock"
echo "  Mounts:  $SCRATCH_DIR (not \$HOME)"
