#!/usr/bin/bash

#
# Host macros session (Git Bash / no ROS).
# Loaded by: ./scripts/setup.bash macros
#

_macros_is_loaded() {
    [[ -n "${_MACROS_LOADED:-}" ]] && declare -F load_macros >/dev/null 2>&1
}

_macros_clear_stale_load_marker() {
    if [[ -n "${_MACROS_LOADED:-}" ]] && ! declare -F load_macros >/dev/null 2>&1; then
        unset _MACROS_LOADED
    fi
}

_macros_set_workspace_root() {
    local session_dir
    session_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export ROS2_PROJECTS_WS_ROOT="$(cd "${session_dir}/../../.." && pwd)"
}

_macros_load_bashrc_if_rcfile() {
    [[ "${_MACROS_SETUP_AS_RCFILE:-}" == "1" ]] || return 0
    export _MACROS_SESSION_RCFILE=1
    unset _MACROS_SETUP_AS_RCFILE

    [[ -f "${HOME}/.bashrc" ]] || return 0
    # shellcheck disable=SC1090
    source "${HOME}/.bashrc"
}

_macros_load() {
    _macros_clear_stale_load_marker

    if _macros_is_loaded; then
        return 0
    fi

    _macros_load_bashrc_if_rcfile
    _macros_clear_stale_load_marker
    if _macros_is_loaded; then
        return 0
    fi

    _macros_set_workspace_root

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/launch/macros.bash" || return 1
    load_macros || return 1

    # shellcheck disable=SC1091
    source "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_macros/include/completion.bash"
    _macros_install_completion_filter

    export _MACROS_LOADED=1
}

_macros_report_load_failure() {
    echo "macros_session: failed to load workspace macros (see errors above)." >&2
    echo "  Recovery: unset _MACROS_LOADED && source scripts/setup.bash macros" >&2
}

if ! _macros_load; then
    unset _MACROS_LOADED
    _macros_report_load_failure
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit 1
    fi
    return 1
fi
