#!/usr/bin/bash

# Private helpers for bash_bringup. Sourced by launch/bringup.bash.

_is_sourced() {
    [[ "${_BRINGUP_SOURCED:-0}" == "1" ]]
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
    unset _mode _runtime _BRINGUP_SOURCED
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
