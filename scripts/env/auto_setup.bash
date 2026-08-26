#!/usr/bin/bash

#
# Container shell bootstrap (sourced from ~/.bashrc via Distrobox).
#
# Loads ROS 2, optional local display, then macros from
# $ROS2_PROJECTS_WS_ROOT/build_ws/macros/.
#

_env_is_loaded() {
    [[ -n "${_ENV_LOADED:-}" ]]
}

_env_set_loaded() {
    export _ENV_LOADED=1
}

_env_get_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

_env_load() {
    if _env_is_loaded; then
        return 0
    fi
    _env_set_loaded

    local env_dir
    env_dir="$(_env_get_dir)"

    # shellcheck disable=SC1091
    source "${env_dir}/modules/ros2.bash"
    # shellcheck disable=SC1091
    source "${env_dir}/modules/display.bash"

    init_ros2_env
    set_local_display_if_available
    unset -f set_xauthority_from_local_candidates

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/macros/api/sync.bash"
    sync_macros
}

_env_load
