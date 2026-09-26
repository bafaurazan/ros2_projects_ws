#!/usr/bin/bash

# Private helpers for bash_bringup. Sourced by launch/bringup.bash.

bringup::_is_sourced() {
    [[ "${_BRINGUP_SOURCED:-0}" == "1" ]]
}

bringup::_print_usage() {
    echo "Usage: ./scripts/setup.bash [-v|--verbose] [humble|jazzy [prod]|macros]"
    echo "       ./scripts/setup.bash [-h|--help]"
    echo "  humble | jazzy       create/enter Distrobox"
    echo "  humble | jazzy prod  production runtime (not implemented yet)"
    echo "  macros               interactive shell with macros (no Distrobox)"
    echo "  -v, --verbose        detailed diagnostic logs (first-boot progress, apt)"
    echo "  -h, --help           show this help"
}

# Parse CLI into _mode / _runtime; export ROS2_PROJECTS_WS_VERBOSE=1 when -v/--verbose.
# Returns: 0 ok, 1 error (usage printed), 2 help (usage printed).
bringup::_parse_cli() {
    _mode=""
    _runtime=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                bringup::_print_usage
                return 2
                ;;
            -v | --verbose)
                # Consumed by Distrobox (and future macros) diagnostic logging.
                export ROS2_PROJECTS_WS_VERBOSE=1
                shift
                ;;
            -*)
                echo "Error: unknown option '${1}'." >&2
                bringup::_print_usage >&2
                return 1
                ;;
            *)
                if [[ -z "${_mode}" ]]; then
                    _mode="$1"
                elif [[ -z "${_runtime}" ]]; then
                    _runtime="$1"
                else
                    echo "Error: unexpected argument '${1}'." >&2
                    bringup::_print_usage >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    return 0
}

bringup::_cleanup() {
    unset -f \
        bringup::_is_sourced \
        bringup::_print_usage \
        bringup::_parse_cli \
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
