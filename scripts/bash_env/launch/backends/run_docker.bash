#!/usr/bin/env bash

#
# Docker / production backend.
# - Executed (host): prod stub (not implemented yet)
# - Sourced (in-image session via DOCKER_SESSION_SETUP): ROS, display, macros (template)
#

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

env::_is_docker_session_loaded() {
    [[ -n "${_ENV_LOADED:-}" ]]
}

env::_set_docker_session_loaded() {
    export _ENV_LOADED=1
}

env::_load_docker_session() {
    if env::_is_docker_session_loaded; then
        return 0
    fi
    env::_set_docker_session_loaded

    # launch/backends → ../../include
    # shellcheck disable=SC1091
    source "${_dir}/../../include/ros2.bash"
    # shellcheck disable=SC1091
    source "${_dir}/../../include/display.bash"

    env::_init_ros2_env
    env::_set_local_display_when_available

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash"
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/lib/completion.bash"
    _install_macros_completion
}

# In-image session hook (sourced) — template until prod runtime wires DOCKER_SESSION_SETUP
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    env::_load_docker_session
    return $?
fi

# Host entry (stub)
set -euo pipefail

# shellcheck disable=SC1091
source "${_dir}/../../config/docker_config.bash"
# shellcheck disable=SC1091
source "${_dir}/../../src/impl_docker.bash"

env::_run_docker "${1:-}"
exit $?
