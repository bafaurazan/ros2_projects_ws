#!/usr/bin/env bash

#
# Host macros backend.
# - Executed: start interactive bash with this file as --rcfile
# - Sourced (from runtime_dispatch or as --rcfile): load workspace macros
#

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_dir}/../../include/macros_session_helpers.bash"

env::_load_macros() {
    env::_clear_stale_load_marker

    if env::_is_macros_loaded; then
        return 0
    fi

    env::_load_host_bashrc
    env::_clear_stale_load_marker
    if env::_is_macros_loaded; then
        return 0
    fi

    env::_set_macros_workspace_root

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash" || return 1
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/lib/completion.bash"
    _install_macros_completion

    export _MACROS_LOADED=1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    export _MACROS_SETUP_AS_RCFILE=1
    exec bash --rcfile "${BASH_SOURCE[0]}" -i
fi

if ! env::_load_macros; then
    unset _MACROS_LOADED
    env::_report_load_failure
    return 1
fi
