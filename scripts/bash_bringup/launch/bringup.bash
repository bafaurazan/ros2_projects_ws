#!/usr/bin/env bash

#
# Workspace CLI router: Distrobox (humble|jazzy), macros, or prod stub.
#
#   ./scripts/setup.bash humble
#   ./scripts/setup.bash jazzy
#   ./scripts/setup.bash macros
#   ./scripts/setup.bash jazzy prod   # reserved — not implemented yet
#
# Optional: source scripts/setup.bash macros  — load macros in the current shell.
#

_bringup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROS2_PROJECTS_WS_ROOT="$(cd "${_bringup_dir}/../../.." && pwd)"
_mode="${1:-}"
_runtime="${2:-}"

_is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "$0" ]]
}

_is_distro_mode() {
    [[ "$1" == "humble" || "$1" == "jazzy" ]]
}

_has_runtime() {
    [[ -n "${1:-}" ]]
}

_print_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]"
    echo "  humble | jazzy       create/enter Distrobox"
    echo "  humble | jazzy prod  production runtime (not implemented yet)"
    echo "  macros               interactive shell with macros (no Distrobox)"
}

_cleanup() {
    unset -f \
        _is_sourced \
        _is_distro_mode \
        _has_runtime \
        _print_usage \
        _cleanup \
        _fail \
        _run_container \
        _run_macros \
        _dispatch
    unset _bringup_dir _mode _runtime
}

_fail() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo "Error: ${message}" >&2
    _print_usage >&2
    if _is_sourced; then
        _cleanup
        return 1
    fi
    exit 1
}

_run_container() {
    exec "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_container/launch/runtime_dispatch.bash" "$_mode" "$_runtime"
}

_run_macros() {
    if _has_runtime "$_runtime"; then
        _fail "mode 'macros' does not take extra arguments."
        return 1
    fi

    local macros_session="${_bringup_dir}/../src/macros_session.bash"

    if _is_sourced; then
        # shellcheck disable=SC1090
        source "$macros_session"
        _macros_status=$?
        _cleanup
        return "$_macros_status"
    fi

    export _MACROS_SETUP_AS_RCFILE=1
    exec bash --rcfile "$macros_session" -i
}

_dispatch() {
    if _is_distro_mode "$_mode"; then
        _run_container
        return 0
    fi

    case "$_mode" in
        macros)
            _run_macros
            return $?
            ;;
        "")
            _fail "missing mode."
            return 1
            ;;
        *)
            _fail "unknown mode '${_mode}'."
            return 1
            ;;
    esac
}

_dispatch
