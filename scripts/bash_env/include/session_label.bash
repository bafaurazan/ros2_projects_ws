#!/usr/bin/bash

# Workspace session label: export ROS2_PROJECTS_WS_SESSION and show it in the shell.
# Prepends "( <session> ) " to PS1 in a terminal-friendly, idempotent way.

env::_has_session_label_installed() {
    local workspace_session_label="${ROS2_PROJECTS_WS_SESSION:-macros}"
    [[ "${_ROS2_PROJECTS_WS_SESSION_LABEL_INSTALLED:-0}" == "1" ]] \
        && [[ "${PS1:-}" == *"( ${workspace_session_label} ) "* ]]
}

env::_set_workspace_session() {
    local workspace_session_label="$1"
    export ROS2_PROJECTS_WS_SESSION="${workspace_session_label}"
}

env::_apply_session_label_format() {
    local workspace_session_label="$1"
    local original_ps1="${PS1:-}"

    if [[ -n "${_ROS2_PROJECTS_WS_SESSION_LABEL:-}" \
        && "${original_ps1}" == *"( ${_ROS2_PROJECTS_WS_SESSION_LABEL} ) "* ]]; then
        # Session label updated in the same shell: replace previous label
        PS1="${original_ps1/"( ${_ROS2_PROJECTS_WS_SESSION_LABEL} ) "/"( ${workspace_session_label} ) "}"
    elif [[ "${original_ps1}" == *'\007\]\n'* ]]; then
        # Git Bash style: window title escape sequence followed by newline
        PS1="${original_ps1/\\007\\\]\\n/\\007\\]\\n( ${workspace_session_label} ) }"
    elif [[ "${original_ps1}" == *'\a\]'* ]]; then
        # Ubuntu / Linux xterm style: window title escape sequence
        PS1="${original_ps1/\\a\\\]/\\a\\]( ${workspace_session_label} ) }"
    elif [[ "${original_ps1}" == *'\007\]'* ]]; then
        # Alternative window title escape sequence without newline
        PS1="${original_ps1/\\007\\\]/\\007\\]( ${workspace_session_label} ) }"
    else
        # Standard plain PS1
        PS1="( ${workspace_session_label} ) ${original_ps1}"
    fi
}

env::_install_session_label() {
    local workspace_session_label="${ROS2_PROJECTS_WS_SESSION:-macros}"

    if env::_has_session_label_installed; then
        return 0
    fi

    if [[ -z "${PS1:-}" ]]; then
        return 0
    fi

    env::_apply_session_label_format "${workspace_session_label}"
    _ROS2_PROJECTS_WS_SESSION_LABEL_INSTALLED=1
    _ROS2_PROJECTS_WS_SESSION_LABEL="${workspace_session_label}"
}

env::_set_session_label() {
    local workspace_session_label="$1"
    env::_set_workspace_session "${workspace_session_label}"
    env::_install_session_label
}
