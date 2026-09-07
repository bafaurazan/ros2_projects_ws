#!/usr/bin/bash

# Private helpers for bash_bringup. Sourced by launch/bringup.bash.

bringup::_is_sourced() {
    [[ "${_BRINGUP_SOURCED:-0}" == "1" ]]
}

bringup::_print_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]"
    echo "  humble | jazzy       create/enter Distrobox"
    echo "  humble | jazzy prod  production runtime (not implemented yet)"
    echo "  macros               interactive shell with macros (no Distrobox)"
}

bringup::_cleanup() {
    unset -f \
        bringup::_is_sourced \
        bringup::_print_usage \
        bringup::_cleanup \
        bringup::_fail \
        bringup::_dispatch
    unset _mode _runtime _BRINGUP_SOURCED
}

bringup::_fail() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo "Error: ${message}" >&2
    bringup::_print_usage >&2
    if bringup::_is_sourced; then
        bringup::_cleanup
        return 1
    fi
    exit 1
}
