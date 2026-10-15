#!/usr/bin/env bash
set -euo pipefail
umask 077

if (( EUID != 0 )); then
  echo 'Run this script as root, for example: sudo bash scripts/deploy-azure.sh' >&2
  exit 1
fi

app_dir="${EQUIPMENT_APP_DIR:-/opt/equipment-app}"
env_file="${EQUIPMENT_ENV_FILE:-/etc/equipment-app.env}"

cd "$app_dir"

if [[ ! -f "$env_file" ]]; then
  echo "Environment file not found: $env_file" >&2
  exit 1
fi

git_in_app() {
  git -c safe.directory="$app_dir" "$@"
}

if [[ -n "$(git_in_app status --porcelain)" ]]; then
  echo 'Refusing to deploy from a dirty checkout.' >&2
  exit 1
fi

# Prevent simultaneous deploys on this instance, including other cloud scripts.
exec 9>/var/lock/equipment-deploy.lock
flock -n 9 || { echo 'Another deployment is running.' >&2; exit 1; }

commit_sha="$(git_in_app rev-parse --verify HEAD)"
export APP_VERSION="$commit_sha"
export EQUIPMENT_IMAGE="ghcr.io/d3duck/equipmenttest:$commit_sha"

dc() {
  docker compose --env-file "$env_file" \
    -f compose.yaml -f compose.https.yaml -f compose.images.yaml "$@"
}

domain="$(sed -n 's/^DOMAIN=//p' "$env_file" | tail -n 1)"
if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+$ ]]; then
  echo "Set a valid DOMAIN in $env_file before deploying." >&2
  exit 1
fi

# A missing image fails here while the currently deployed app is still running.
echo "Pulling $EQUIPMENT_IMAGE"
dc pull app-backend caddy

# Keep later Compose commands aligned with the image deployed by this script.
if grep -q '^APP_VERSION=' "$env_file"; then
  sed -i "s|^APP_VERSION=.*|APP_VERSION=$APP_VERSION|" "$env_file"
else
  printf 'APP_VERSION=%s\n' "$APP_VERSION" >> "$env_file"
fi

if grep -q '^EQUIPMENT_IMAGE=' "$env_file"; then
  sed -i "s|^EQUIPMENT_IMAGE=.*|EQUIPMENT_IMAGE=$EQUIPMENT_IMAGE|" "$env_file"
else
  printf 'EQUIPMENT_IMAGE=%s\n' "$EQUIPMENT_IMAGE" >> "$env_file"
fi

if grep -q '^APP_BIND_ADDRESS=' "$env_file"; then
  sed -i 's|^APP_BIND_ADDRESS=.*|APP_BIND_ADDRESS=127.0.0.1|' "$env_file"
else
  printf 'APP_BIND_ADDRESS=127.0.0.1\n' >> "$env_file"
fi

if grep -q '^GO_PORT=' "$env_file"; then
  sed -i 's|^GO_PORT=.*|GO_PORT=8080|' "$env_file"
else
  printf 'GO_PORT=8080\n' >> "$env_file"
fi

echo 'Stopping backend for migrations'
dc stop app-backend

# Keep a protected pre-migration backup outside the repository.
install -d -m 700 /var/backups/equipment
backup="/var/backups/equipment/$(date -u +%Y%m%dT%H%M%SZ).dump"
dc exec -T postgres sh -c \
  'exec pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' > "$backup"
test -s "$backup"
echo "Database backup saved to $backup"

# Failure deliberately leaves the backend stopped for investigation.
echo 'Applying Atlas migrations'
dc run --rm --no-deps atlas

echo 'Starting downloaded app image'
dc up -d --no-deps --no-build app-backend
dc up -d --no-deps caddy

published_port="$(dc port app-backend 8080 | awk -F: 'NR == 1 { print $NF }')"
if [[ ! "$published_port" =~ ^[0-9]+$ ]]; then
  echo 'Could not determine the published application port.' >&2
  exit 1
fi

curl --fail --show-error \
  --retry 12 --retry-all-errors --retry-delay 5 \
  --connect-timeout 5 --max-time 10 \
  "http://127.0.0.1:$published_port/health"

echo "Checking HTTPS for $domain"
curl --fail --show-error \
  --retry 24 --retry-all-errors --retry-delay 5 \
  --connect-timeout 5 --max-time 10 \
  --resolve "$domain:443:127.0.0.1" \
  "https://$domain/health"

dc ps
