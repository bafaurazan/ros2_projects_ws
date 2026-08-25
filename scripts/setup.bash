#!/usr/bin/env bash

#
# Public workspace entry: Distrobox (humble|jazzy) or host macros.
#
#   ./scripts/setup.bash humble
#   ./scripts/setup.bash jazzy
#   ./scripts/setup.bash host
#
# Optional: source scripts/setup.bash host  — load macros in the current shell.
#

_setup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_setup_mode="${1:-}"

_setup_is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "$0" ]]
}

_setup_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy|host]"
    echo "  humble | jazzy  create/enter Distrobox"
    echo "  host            interactive shell with macros (no Distrobox)"
}

_setup_cleanup() {
    unset -f _setup_is_sourced _setup_usage _setup_cleanup
    unset _setup_dir _setup_mode
}

case "$_setup_mode" in
    humble|jazzy)
        exec "${_setup_dir}/env/distrobox" "$_setup_mode"
        ;;
    host)
        if _setup_is_sourced; then
            # shellcheck disable=SC1091
            source "${_setup_dir}/host/setup.bash"
            _setup_cleanup
        else
            export _HOST_SETUP_AS_RCFILE=1
            exec bash --rcfile "${_setup_dir}/host/setup.bash" -i
        fi
        ;;
    *)
        if [[ -z "$_setup_mode" ]]; then
            echo "Error: missing mode." >&2
        else
            echo "Error: unknown mode '${_setup_mode}'." >&2
        fi
        _setup_usage >&2
        if _setup_is_sourced; then
            _setup_cleanup
            return 1
        fi
        exit 1
        ;;
esac
