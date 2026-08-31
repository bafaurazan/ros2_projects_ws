#!/usr/bin/bash

#
# Container session bootstrap (sourced from ~/.bashrc inside the container).
#
# Loads ROS 2, optional local display, then macros from
# scripts/bash_macros/ under the workspace (sourced in place).
#

_is_session_loaded() {
    [[ -n "${_ENV_LOADED:-}" ]]
}

_set_session_loaded() {
    export _ENV_LOADED=1
}

_get_session_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

_load_session() {
    if _is_session_loaded; then
        return 0
    fi
    _set_session_loaded

    local session_dir
    session_dir="$(_get_session_dir)"

    # shellcheck disable=SC1091
    source "${session_dir}/../include/ros2.bash"
    # shellcheck disable=SC1091
    source "${session_dir}/../include/display.bash"

    _init_ros2_env
    _set_local_display_when_available
    unset -f _set_xauthority_from_local_candidates

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash"
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/include/completion.bash"
    _install_completion_filter
}

_load_session
