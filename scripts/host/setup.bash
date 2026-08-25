#!/usr/bin/bash

#
# Host-only macros (Git Bash / no Distrobox).
# Loaded by: ./scripts/setup.bash host
#

if [[ -n "${_MACROS_LOADED:-}" ]]; then
    return
fi

if [[ "${_HOST_SETUP_AS_RCFILE:-}" == "1" ]]; then
    unset _HOST_SETUP_AS_RCFILE
    if [[ -f "${HOME}/.bashrc" ]]; then
        # shellcheck disable=SC1090
        source "${HOME}/.bashrc"
        if [[ -n "${_MACROS_LOADED:-}" ]]; then
            return
        fi
    fi
fi

export _MACROS_LOADED=1

_host_setup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROS2_PROJECTS_WS_ROOT="$(cd "${_host_setup_dir}/../.." && pwd)"
unset _host_setup_dir

# shellcheck disable=SC1091
source "${ROS2_PROJECTS_WS_ROOT}/scripts/macros/sync.bash"
sync_macros
