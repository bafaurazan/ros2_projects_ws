#!/usr/bin/bash

#
# Container session bootstrap (sourced from ~/.bashrc inside the container).
#
# Loads ROS 2, optional local display, then macros from
# scripts/bash_macros/ under the workspace (sourced in place).
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

    local session_dir
    session_dir="$(_env_get_dir)"

    # shellcheck disable=SC1091
    source "${session_dir}/../include/ros2.bash"
    # shellcheck disable=SC1091
    source "${session_dir}/../include/display.bash"

    init_ros2_env
    set_local_display_if_available
    unset -f set_xauthority_from_local_candidates

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash"
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/include/completion.bash"
    _install_completion_filter
}

_env_load
