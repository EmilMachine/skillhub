#!/usr/bin/env bash
# Start the isolated DinD daemon used by the nono sandbox.
# Idempotent — safe to call even if the container is already running.
#
# After this script exits:
#   Socket:  /tmp/mysubnetwork-dind/docker.sock
#   Env:     DOCKER_HOST=unix:///tmp/mysubnetwork-dind/docker.sock
#
# Stop with:  nono/docker_linux_dind/stop-dind.sh
set -euo pipefail

CONTAINER="mysubnetwork-dind"
NETWORK="mysubnetwork-dind-net"
VOLUME="mysubnetwork-dind-storage"
SOCK="/tmp/mysubnetwork-dind/docker.sock"

if docker inspect "$CONTAINER" &>/dev/null; then
  echo "✓ DinD container '$CONTAINER' already running"
  echo "  Socket: $SOCK"
  exit 0
fi

echo "▶ Creating network '$NETWORK'..."
docker network create "$NETWORK" 2>/dev/null || true

mkdir -p /tmp/mysubnetwork-dind

echo "▶ Starting DinD container '$CONTAINER'..."
docker run -d --rm \
  --name "$CONTAINER" \
  --privileged \
  --network "$NETWORK" \
  -v "${VOLUME}:/var/lib/docker" \
  -v "/tmp/mysubnetwork-dind:/var/run" \
  docker:dind \
  --host unix:///var/run/docker.sock

echo -n "  Waiting for daemon to be ready..."
until docker -H "unix://$SOCK" version &>/dev/null 2>&1; do
  echo -n "."
  sleep 0.5
done
echo " ready"

echo
echo "✓ DinD daemon is up."
echo "  Socket:  $SOCK"
echo "  Export:  export DOCKER_HOST=unix://$SOCK"
