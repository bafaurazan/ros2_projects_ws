#!/usr/bin/bash

#
# Container session bootstrap (sourced from ~/.bashrc inside the container).
#
# Loads ROS 2, optional local display, then macros from
# scripts/bash_macros/ under the workspace (sourced in place).
#

container::_is_session_loaded() {
    [[ -n "${_ENV_LOADED:-}" ]]
}

container::_set_session_loaded() {
    export _ENV_LOADED=1
}

container::_get_session_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

container::_load_session() {
    if container::_is_session_loaded; then
        return 0
    fi
    container::_set_session_loaded

    local session_dir
    session_dir="$(container::_get_session_dir)"

    # shellcheck disable=SC1091
    source "${session_dir}/../include/ros2.bash"
    # shellcheck disable=SC1091
    source "${session_dir}/../include/display.bash"

    container::_init_ros2_env
    container::_set_local_display_when_available

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash"
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/include/completion.bash"
    _install_macros_completion
}

container::_load_session
