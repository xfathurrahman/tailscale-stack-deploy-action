#!/bin/bash
set -e

# Input parameters
TAILSCALE_HOST="${INPUT_TAILSCALE_HOST}"  # Tailscale host to resolve
DOCKER_PORT="${INPUT_DOCKER_PORT:-2375}" # Default Docker port
DOCKER_FILE="${INPUT_COMPOSE_FILE:-docker-compose.yaml}" # Stack definition file
STACK_NAME="${INPUT_STACK_NAME}" # Name of the Docker stack
ENV_FILE="${INPUT_ENV_FILE:-}" # Optional environment file

# Function to resolve hostname to IP
resolve_host_to_ip() {
  local host=$1
  local ip
  if ! ip=$(getent hosts "$host" | awk '{ print $1 }'); then
    >&2 echo "Unable to resolve hostname $host. Ensure Magic DNS is working."
    exit 1
  fi
  echo "$ip"  # Only print the resolved IP
}

# Function to source environment variables from an optional file
source_env_file() {
  local env_file=$1
  if [ -n "$env_file" ]; then
    echo "Sourcing environment variables from $env_file"
    set -o allexport
    # shellcheck disable=SC1090
    source "$env_file"
    set +o allexport
  fi
}

# Resolve Tailscale host to IP
RESOLVED_IP="$(resolve_host_to_ip "$TAILSCALE_HOST")"

# Set and export Docker host environment variable
DOCKER_HOST="tcp://$RESOLVED_IP:$DOCKER_PORT"
export DOCKER_HOST

# Source environment variables if an env file is specified
source_env_file "$ENV_FILE"

# Deploy the Docker stack
docker stack deploy -c "$DOCKER_FILE" --with-registry-auth --detach=false "$STACK_NAME"