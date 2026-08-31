#!/usr/bin/bash

#
# Host macros session (Git Bash / no ROS).
# Loaded by: ./scripts/setup.bash macros
#

_session_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_session_dir}/../include/macros_session_helpers.bash"
unset _session_dir

# Bootstrap this session, then call public load_macros to discover bundles.
_load_macros() {
    _clear_stale_load_marker

    if _is_macros_loaded; then
        return 0
    fi

    _load_host_bashrc
    _clear_stale_load_marker
    if _is_macros_loaded; then
        return 0
    fi

    _set_macros_workspace_root

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash" || return 1
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/include/completion.bash"
    _install_completion_filter

    export _MACROS_LOADED=1
}

if ! _load_macros; then
    unset _MACROS_LOADED
    _report_load_failure
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit 1
    fi
    return 1
fi
