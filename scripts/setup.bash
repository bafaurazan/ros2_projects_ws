#!/usr/bin/env bash

#
# Public workspace entry: Distrobox (humble|jazzy), macros, or prod stub.
#
#   ./scripts/setup.bash humble
#   ./scripts/setup.bash jazzy
#   ./scripts/setup.bash macros
#   ./scripts/setup.bash jazzy prod   # reserved — not implemented yet
#
# Optional: source scripts/setup.bash macros  — load macros in the current shell.
#

_setup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_setup_mode="${1:-}"
_setup_runtime="${2:-}"

_setup_is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "$0" ]]
}

_setup_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]"
    echo "  humble | jazzy       create/enter Distrobox"
    echo "  humble | jazzy prod  production runtime (not implemented yet)"
    echo "  macros               interactive shell with macros (no Distrobox)"
}

_setup_cleanup() {
    unset -f _setup_is_sourced _setup_usage _setup_cleanup
    unset _setup_dir _setup_mode _setup_runtime
}

_setup_exit_error() {
    _setup_usage >&2
    if _setup_is_sourced; then
        _setup_cleanup
        return 1
    fi
    exit 1
}

case "$_setup_mode" in
    humble|jazzy)
        if [[ -z "$_setup_runtime" ]]; then
            exec "${_setup_dir}/env/distrobox" "$_setup_mode"
        elif [[ "$_setup_runtime" == "prod" ]]; then
            echo "Error: production runtime ('${_setup_mode} prod') is not implemented yet." >&2
            echo "See README.md TODO for Docker/Podman production entry." >&2
            _setup_exit_error
            return 1
        else
            echo "Error: unknown runtime '${_setup_runtime}' (expected 'prod' or none)." >&2
            _setup_exit_error
            return 1
        fi
        ;;
    macros)
        if [[ -n "$_setup_runtime" ]]; then
            echo "Error: mode 'macros' does not take extra arguments." >&2
            _setup_exit_error
            return 1
        fi
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
        _setup_exit_error
        return 1
        ;;
esac
