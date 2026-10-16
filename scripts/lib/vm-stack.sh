#!/usr/bin/env bash

app_dir="${EQUIPMENT_APP_DIR:-/opt/equipment-app}"
env_file="${EQUIPMENT_ENV_FILE:-/etc/equipment-app.env}"
compose_args=(-f compose.yaml -f compose.https.yaml)

require_root() {
  if (( EUID != 0 )); then
    echo "Run this script as root, for example: sudo bash $1" >&2
    exit 1
  fi
}

install_host_dependencies() {
  local packages=(ca-certificates curl git openssl util-linux)

  if ! command -v docker >/dev/null 2>&1; then
    if ! command -v apt-get >/dev/null 2>&1; then
      echo 'Automatic Docker installation is supported only on Ubuntu/Debian.' >&2
      echo 'Install Docker Engine and the Compose plugin, then rerun this script.' >&2
      exit 1
    fi

    packages+=(docker.io docker-compose-v2)
  fi

  local missing=false
  local command_name
  for command_name in curl git openssl flock; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      missing=true
      break
    fi
  done

  if [[ "$missing" == true ]] || ! command -v docker >/dev/null 2>&1; then
    if ! command -v apt-get >/dev/null 2>&1; then
      echo 'Install the missing host commands manually, then rerun this script.' >&2
      exit 1
    fi

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y "${packages[@]}"
  fi

  if ! docker compose version >/dev/null 2>&1; then
    echo 'Docker is installed without the Compose v2 plugin.' >&2
    echo 'Install Docker Compose v2, then rerun this script.' >&2
    exit 1
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now docker
  fi
}

require_host_dependencies() {
  local command_name
  for command_name in awk curl docker flock git sed; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      echo "Required command not found: $command_name" >&2
      exit 1
    fi
  done

  docker compose version >/dev/null
  docker info >/dev/null
}

enter_app_directory() {
  if [[ ! -d "$app_dir/.git" ]]; then
    echo "Git checkout not found: $app_dir" >&2
    exit 1
  fi

  cd "$app_dir" || exit 1
}

git_in_app() {
  git -c safe.directory="$app_dir" "$@"
}

require_clean_checkout() {
  if [[ -n "$(git_in_app status --porcelain)" ]]; then
    echo 'Refusing to use a dirty checkout.' >&2
    exit 1
  fi
}

acquire_deployment_lock() {
  exec 9>/var/lock/equipment-deploy.lock
  flock -n 9 || { echo 'Another deployment is running.' >&2; exit 1; }
}

dc() {
  docker compose --env-file "$env_file" "${compose_args[@]}" "$@"
}

env_value() {
  local key="$1"
  awk -F= -v key="$key" '
    $1 == key {
      sub(/^[^=]*=/, "")
      value = $0
    }
    END { print value }
  ' "$env_file"
}

upsert_env_value() {
  local key="$1"
  local value="$2"
  local escaped_value

  if [[ "$value" == *$'\n'* ]]; then
    echo "Refusing to write a multiline value for $key." >&2
    exit 1
  fi

  escaped_value="${value//&/\\&}"
  escaped_value="${escaped_value//|/\\|}"

  if grep -q "^${key}=" "$env_file"; then
    sed -i "s|^${key}=.*|${key}=${escaped_value}|" "$env_file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$env_file"
  fi
}

configure_private_bindings() {
  chown root:root "$env_file"
  chmod 600 "$env_file"
  upsert_env_value ENVIRONMENT production
  upsert_env_value APP_BIND_ADDRESS 127.0.0.1
  upsert_env_value GO_PORT 8080
  upsert_env_value POSTGRES_BIND_ADDRESS 127.0.0.1
  upsert_env_value POSTGRES_PORT 5432
}

validate_environment() {
  local domain
  local required_key

  if [[ ! -f "$env_file" ]]; then
    echo "Environment file not found: $env_file" >&2
    exit 1
  fi

  for required_key in POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB JWT_SECRET DOMAIN; do
    if [[ -z "$(env_value "$required_key")" ]]; then
      echo "Required setting is missing from $env_file: $required_key" >&2
      exit 1
    fi
  done

  if [[ -z "$(env_value EQUIPMENT_IMAGE)" ]] && [[ -z "${EQUIPMENT_IMAGE:-}" ]]; then
    echo "Required setting is missing from $env_file: EQUIPMENT_IMAGE" >&2
    exit 1
  fi

  domain="$(env_value DOMAIN)"
  if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+$ ]]; then
    echo "DOMAIN is invalid in $env_file: $domain" >&2
    exit 1
  fi

  if [[ "$(env_value APP_BIND_ADDRESS)" != '127.0.0.1' ]] ||
    [[ "$(env_value GO_PORT)" != '8080' ]] ||
    [[ "$(env_value POSTGRES_BIND_ADDRESS)" != '127.0.0.1' ]]; then
    echo "Application or database bindings in $env_file are not private." >&2
    exit 1
  fi

  dc config --quiet
}

wait_for_postgres() {
  local attempt
  for ((attempt = 1; attempt <= 30; attempt++)); do
    # Variables expand inside the PostgreSQL container.
    # shellcheck disable=SC2016
    if dc exec -T postgres sh -c \
      'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' >/dev/null 2>&1; then
      return
    fi
    sleep 2
  done

  echo 'PostgreSQL did not become ready.' >&2
  return 1
}

check_local_health() {
  curl --fail --show-error \
    --retry 12 --retry-all-errors --retry-delay 5 \
    --connect-timeout 5 --max-time 10 \
    http://127.0.0.1:8080/health
}

check_https_health() {
  local domain
  domain="$(env_value DOMAIN)"

  curl --fail --show-error \
    --retry 24 --retry-all-errors --retry-delay 5 \
    --connect-timeout 5 --max-time 10 \
    --resolve "$domain:443:127.0.0.1" \
    "https://$domain/health"
}
