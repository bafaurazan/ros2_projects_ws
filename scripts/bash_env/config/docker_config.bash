#!/usr/bin/bash

# Docker / production runtime constants. Sourced by launch/backends/run_docker.bash (host entry).

_config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS_DIR="$(cd "${_config_dir}/../../.." && pwd)"

# Placeholder: image, network, and volume settings will live here.
# Session hook for the production image (same file as host entry; sourced in-image).
DOCKER_SESSION_SETUP="${WS_DIR}/scripts/bash_env/launch/backends/run_docker.bash"
