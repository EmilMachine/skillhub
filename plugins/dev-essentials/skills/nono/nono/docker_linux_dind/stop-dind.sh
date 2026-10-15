#!/usr/bin/env bash
# Stop the DinD container and clean up its volume and network.
# Safe to run even if the container is not running.
set -euo pipefail

CONTAINER="mysubnetwork-dind"
NETWORK="mysubnetwork-dind-net"
VOLUME="mysubnetwork-dind-storage"

if docker inspect "$CONTAINER" &>/dev/null; then
  echo "■ Stopping DinD container '$CONTAINER'..."
  docker stop "$CONTAINER"
else
  echo "✓ DinD container '$CONTAINER' not running"
fi

echo "■ Removing volume '$VOLUME'..."
docker volume rm "$VOLUME" 2>/dev/null || true

echo "■ Removing network '$NETWORK'..."
docker network rm "$NETWORK" 2>/dev/null || true

rm -rf /tmp/mysubnetwork-dind

echo "✓ Done."
