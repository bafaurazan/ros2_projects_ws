#!/usr/bin/bash

# Private helpers for the host macros session.

_is_macros_loaded() {
    [[ -n "${_MACROS_LOADED:-}" ]] && declare -F load_macros >/dev/null 2>&1
}

_clear_stale_load_marker() {
    if [[ -n "${_MACROS_LOADED:-}" ]] && ! declare -F load_macros >/dev/null 2>&1; then
        unset _MACROS_LOADED
    fi
}

_set_macros_workspace_root() {
    local helpers_dir
    helpers_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export ROS2_PROJECTS_WS_ROOT="$(cd "${helpers_dir}/../../.." && pwd)"
}

# When this session is bash --rcfile, source ~/.bashrc first (interactive profile).
_load_host_bashrc() {
    [[ "${_MACROS_SETUP_AS_RCFILE:-}" == "1" ]] || return 0
    export _MACROS_SESSION_RCFILE=1
    unset _MACROS_SETUP_AS_RCFILE

    [[ -f "${HOME}/.bashrc" ]] || return 0
    # shellcheck disable=SC1090
    source "${HOME}/.bashrc"
}

_report_load_failure() {
    echo "macros_session: failed to load workspace macros (see errors above)." >&2
    echo "  Recovery: unset _MACROS_LOADED && source scripts/setup.bash macros" >&2
}
