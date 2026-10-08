#!/usr/bin/env bash
set -euo pipefail
umask 077
cd /opt/equipment-app

# Prevent simultaneous deploys on this instance.
exec 9>/var/lock/equipment-deploy.lock
flock -n 9 || { echo 'Another deployment is running.' >&2; exit 1; }

export EQUIPMENT_IMAGE="ghcr.io/d3duck/equipmenttest:$(git rev-parse HEAD)"
dc() {
  docker compose --env-file .env.aws \
    -f compose.yaml -f compose.https.yaml -f compose.images.yaml "$@"
}

# A missing/private image fails here, before downtime.
echo "Pulling $EQUIPMENT_IMAGE"
dc pull app-backend

echo 'Stopping backend for migrations'
dc stop app-backend

# Keep a protected pre-migration backup outside the repository.
mkdir -p /var/backups/equipment
backup="/var/backups/equipment/$(date -u +%Y%m%dT%H%M%SZ).dump"
dc exec -T postgres sh -c 'exec pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' > "$backup"
test -s "$backup"
echo "Database backup saved to $backup"

# Failure deliberately leaves the backend stopped for investigation.
echo 'Applying Atlas migrations'
dc run --rm --no-deps atlas

echo 'Starting downloaded app image'
dc up -d --no-deps --no-build app-backend
curl --fail --show-error \
  --retry 12 --retry-connrefused --retry-delay 5 \
  http://127.0.0.1:8080/health
dc ps
