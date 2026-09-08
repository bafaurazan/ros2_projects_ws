#!/usr/bin/env bash

#
# Distrobox backend.
# - Executed (host): create/enter ros2_projects_ws_<distro>
# - Sourced (in-container ~/.bashrc via CONTAINER_SESSION_SETUP): ROS, display, macros
#

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

env::_is_distrobox_session_loaded() {
    [[ -n "${_ENV_LOADED:-}" ]]
}

env::_set_distrobox_session_loaded() {
    export _ENV_LOADED=1
}

env::_load_distrobox_session() {
    if env::_is_distrobox_session_loaded; then
        return 0
    fi
    env::_set_distrobox_session_loaded

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

# In-container bashrc hook (sourced)
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    env::_load_distrobox_session
    return $?
fi

# Host entry
set -euo pipefail

# shellcheck disable=SC1091
source "${_dir}/../../config/distrobox_config.bash" "${1:-}"
# shellcheck disable=SC1091
source "${_dir}/../../src/impl_distrobox.bash"

env::_run_distrobox
