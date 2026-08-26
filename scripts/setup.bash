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

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

_is_prod_runtime() {
    [[ "${1:-}" == "prod" ]]
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
        _is_prod_runtime \
        _print_usage \
        _cleanup \
        _fail \
        _run_distrobox \
        _run_prod_stub \
        _run_macros \
        _dispatch
    unset _dir _mode _runtime
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

_run_distrobox() {
    exec "${_dir}/env/distrobox" "$_mode"
}

_run_prod_stub() {
    echo "Error: production runtime ('${_mode} prod') is not implemented yet." >&2
    echo "See README.md TODO for Docker/Podman production entry." >&2
    _fail
    return 1
}

_run_macros() {
    if _has_runtime "$_runtime"; then
        _fail "mode 'macros' does not take extra arguments."
        return 1
    fi

    if _is_sourced; then
        # shellcheck disable=SC1091
        source "${_dir}/host/setup.bash"
        _cleanup
        return 0
    fi

    export _MACROS_SETUP_AS_RCFILE=1
    exec bash --rcfile "${_dir}/host/setup.bash" -i
}

_dispatch() {
    if _is_distro_mode "$_mode"; then
        if ! _has_runtime "$_runtime"; then
            _run_distrobox
        elif _is_prod_runtime "$_runtime"; then
            _run_prod_stub
            return 1
        else
            _fail "unknown runtime '${_runtime}' (expected 'prod' or none)."
            return 1
        fi
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
