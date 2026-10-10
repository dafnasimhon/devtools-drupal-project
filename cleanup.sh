#!/usr/bin/env bash
set -Eeuo pipefail

DB_CONTAINER="${DB_CONTAINER:-drupal-db}"
DRUPAL_CONTAINER="${DRUPAL_CONTAINER:-drupal-app}"
NETWORK_NAME="${NETWORK_NAME:-drupal-network}"
DB_VOLUME="${DB_VOLUME:-drupal-db-data}"
DRUPAL_FILES_VOLUME="${DRUPAL_FILES_VOLUME:-drupal-files-data}"

echo "Cleaning Docker resources for the Drupal project..."

for container in "$DRUPAL_CONTAINER" "$DB_CONTAINER"; do
  if docker ps -a --format '{{.Names}}' | grep -qx "$container"; then
    echo "Stopping and removing container: $container"
    docker rm -f "$container" >/dev/null
  else
    echo "Container not found, skipping: $container"
  fi
done

for volume in "$DB_VOLUME" "$DRUPAL_FILES_VOLUME"; do
  if docker volume ls --format '{{.Name}}' | grep -qx "$volume"; then
    echo "Removing volume: $volume"
    docker volume rm "$volume" >/dev/null
  else
    echo "Volume not found, skipping: $volume"
  fi
done

if docker network ls --format '{{.Name}}' | grep -qx "$NETWORK_NAME"; then
  echo "Removing network: $NETWORK_NAME"
  docker network rm "$NETWORK_NAME" >/dev/null
else
  echo "Network not found, skipping: $NETWORK_NAME"
fi

for image in drupal:latest mysql:latest; do
  if docker image inspect "$image" >/dev/null 2>&1; then
    echo "Removing image if it is not used by another container: $image"
    docker image rm "$image" >/dev/null 2>&1 || echo "Image is still in use or already removed: $image"
  else
    echo "Image not found, skipping: $image"
  fi
done

echo "Cleanup completed."
echo "Backup files in the repository were kept so the site can be restored again."
