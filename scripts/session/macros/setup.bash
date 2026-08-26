#!/usr/bin/bash

#
# Host session (Git Bash / no ROS).
# Loaded by: ./scripts/setup.bash macros
#

_macros_is_loaded() {
    [[ -n "${_MACROS_LOADED:-}" ]]
}

_macros_set_workspace_root() {
    local session_dir
    session_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export ROS2_PROJECTS_WS_ROOT="$(cd "${session_dir}/../../.." && pwd)"
}

_macros_load_bashrc_if_rcfile() {
    [[ "${_MACROS_SETUP_AS_RCFILE:-}" == "1" ]] || return 0
    unset _MACROS_SETUP_AS_RCFILE

    [[ -f "${HOME}/.bashrc" ]] || return 0
    # shellcheck disable=SC1090
    source "${HOME}/.bashrc"
}

_macros_load() {
    if _macros_is_loaded; then
        return 0
    fi

    _macros_load_bashrc_if_rcfile
    if _macros_is_loaded; then
        return 0
    fi

    export _MACROS_LOADED=1
    _macros_set_workspace_root

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/macros/api/load.bash"
    load_macros
}

_macros_load
