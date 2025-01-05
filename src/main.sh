#!/bin/bash
set -e

# Input parameters
TAILSCALE_HOST="${INPUT_TAILSCALE_HOST}"
DOCKER_PORT="${INPUT_DOCKER_PORT:-2375}"
DOCKER_FILE="${INPUT_COMPOSE_FILE:-docker-compose.yaml}"
STACK_NAME="${INPUT_STACK_NAME}"
ENV_FILE="${INPUT_ENV_FILE:-}"

# Resolve hostname to IP (fallback if necessary)
echo "Resolving Tailscale host: $TAILSCALE_HOST"
if ! RESOLVED_IP=$(getent hosts "$TAILSCALE_HOST" | awk '{ print $1 }'); then
  echo "Unable to resolve hostname $TAILSCALE_HOST. Ensure Magic DNS is working."
  exit 1
fi

# Set Docker host
DOCKER_HOST="tcp://$RESOLVED_IP:$DOCKER_PORT"

# Export Docker host for the stack deployment
export DOCKER_HOST

# Deploy stack
if [ -n "$ENV_FILE" ]; then
  docker stack deploy -c "$DOCKER_FILE" --with-registry-auth --env-file "$ENV_FILE" "$STACK_NAME"
else
  docker stack deploy -c "$DOCKER_FILE" --with-registry-auth "$STACK_NAME"
fi
