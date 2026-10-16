#!/usr/bin/env bash
set -euo pipefail
umask 077

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/vm-stack.sh
source "$script_dir/lib/vm-stack.sh"

require_root "scripts/$(basename "$0")"
require_host_dependencies
enter_app_directory
require_clean_checkout
acquire_deployment_lock

if [[ ! -f "$env_file" ]]; then
  echo "Environment file not found: $env_file" >&2
  echo 'Run the bootstrap script for the first deployment.' >&2
  exit 1
fi

commit_sha="$(git_in_app rev-parse --verify HEAD)"
export APP_VERSION="$commit_sha"
export EQUIPMENT_IMAGE="ghcr.io/d3duck/equipmenttest:$commit_sha"

configure_private_bindings

# Process environment values let Compose pull the new image before the release
# values are persisted to the protected environment file.
validate_environment

echo "Pulling $EQUIPMENT_IMAGE and the configured Caddy image"
dc pull app-backend caddy

upsert_env_value APP_VERSION "$APP_VERSION"
upsert_env_value EQUIPMENT_IMAGE "$EQUIPMENT_IMAGE"

if [[ -z "$(dc ps -q postgres)" ]]; then
  echo 'PostgreSQL is not running; refusing an update deployment.' >&2
  echo 'Use the bootstrap script for a new VM or investigate the existing stack.' >&2
  exit 1
fi

echo 'Stopping backend for a consistent pre-migration backup'
dc stop app-backend

install -d -m 700 /var/backups/equipment
backup="/var/backups/equipment/$(date -u +%Y%m%dT%H%M%SZ).dump"
# Variables expand inside the PostgreSQL container.
# shellcheck disable=SC2016
dc exec -T postgres sh -c \
  'exec pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' > "$backup"
test -s "$backup"
echo "Database backup saved to $backup"

# Failure deliberately leaves the backend stopped for investigation.
echo 'Applying Atlas migrations'
dc run --rm --no-deps atlas

echo 'Starting downloaded app image and reconciling Caddy'
dc up -d --no-deps --no-build app-backend
check_local_health
dc up -d --no-deps caddy
check_https_health

dc ps
echo "Deployment completed successfully: $commit_sha"
