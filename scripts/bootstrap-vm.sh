#!/usr/bin/env bash
set -euo pipefail
umask 077

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/vm-stack.sh
source "$script_dir/lib/vm-stack.sh"

require_root "scripts/$(basename "$0")"
install_host_dependencies
require_host_dependencies
enter_app_directory
require_clean_checkout
acquire_deployment_lock

if [[ -f "$env_file" ]]; then
  domain="$(env_value DOMAIN)"
else
  domain="${DOMAIN:-}"
fi
if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+$ ]]; then
  echo 'Pass the public DNS name when starting the bootstrap:' >&2
  echo "  sudo DOMAIN=equipment.example.com bash scripts/$(basename "$0")" >&2
  exit 1
fi

existing_app="$(
  docker ps -aq \
    --filter label=com.docker.compose.project=equipment \
    --filter label=com.docker.compose.service=app-backend
)"
commit_sha="$(git_in_app rev-parse --verify HEAD)"

if [[ -f "$env_file" ]]; then
  if [[ -n "$existing_app" ]]; then
    echo 'This VM is already bootstrapped; use the deployment script instead.' >&2
    exit 1
  fi
  echo "Resuming bootstrap with $env_file"
else
  if docker volume inspect equipment_postgres_data >/dev/null 2>&1 ||
    [[ -n "$(docker ps -aq --filter label=com.docker.compose.project=equipment)" ]]; then
    echo "Existing equipment containers or data were found without $env_file." >&2
    echo 'Refusing to generate replacement database credentials.' >&2
    exit 1
  fi

  temp_env="$(mktemp)"
  trap 'rm -f "$temp_env"' EXIT

  printf '%s\n' \
    'ENVIRONMENT=production' \
    "APP_VERSION=$commit_sha" \
    'APP_BIND_ADDRESS=127.0.0.1' \
    'GO_PORT=8080' \
    'POSTGRES_BIND_ADDRESS=127.0.0.1' \
    'POSTGRES_PORT=5432' \
    'POSTGRES_USER=equipment' \
    "POSTGRES_PASSWORD=$(openssl rand -hex 24)" \
    'POSTGRES_DB=equipment' \
    "JWT_SECRET=$(openssl rand -hex 32)" \
    "EQUIPMENT_IMAGE=ghcr.io/d3duck/equipmenttest:$commit_sha" \
    "DOMAIN=$domain" \
    'TZ=Australia/Sydney' > "$temp_env"

  install -m 600 "$temp_env" "$env_file"
  rm -f "$temp_env"
  trap - EXIT
  echo "Created protected environment file: $env_file"
fi

upsert_env_value APP_VERSION "$commit_sha"
upsert_env_value EQUIPMENT_IMAGE "ghcr.io/d3duck/equipmenttest:$commit_sha"
configure_private_bindings
validate_environment

echo 'Pulling application and infrastructure images'
dc pull

echo 'Starting PostgreSQL'
dc up -d postgres
wait_for_postgres

echo 'Applying Atlas migrations'
dc run --rm --no-deps atlas

echo 'Starting application and Caddy'
dc up -d --no-deps --no-build app-backend
check_local_health
dc up -d --no-deps caddy
check_https_health

dc ps
echo 'Initial deployment completed successfully.'
