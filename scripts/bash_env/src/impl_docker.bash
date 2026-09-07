#!/usr/bin/bash

# Production Docker/Podman backend functions. Sourced by launch/backends/run_docker.bash.
# Target session hook: same file sourced in-image (DOCKER_SESSION_SETUP).

env::_run_docker() {
    local mode="${1:-}"

    echo "Error: production runtime ('${mode} prod') is not implemented yet." >&2
    echo "See README.md TODO for Docker/Podman production entry." >&2
    echo "Session template: scripts/bash_env/launch/backends/run_docker.bash (sourced in-image)" >&2
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]" >&2
    return 1
}
