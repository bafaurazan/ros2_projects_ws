#!/usr/bin/env bash

#
# Runtime dispatcher (host): macros, Distrobox, or Docker (prod stub).
#
# Usage:
#   ./scripts/setup.bash macros
#   ./scripts/setup.bash humble|jazzy
#   ./scripts/setup.bash humble|jazzy prod
#

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_mode="${1:-}"
_runtime="${2:-}"

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    _ENV_SOURCED=1
else
    _ENV_SOURCED=0
fi

env::_print_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]" >&2
    echo "  humble | jazzy       Distrobox runtime" >&2
    echo "  humble | jazzy prod  production runtime (not implemented yet)" >&2
    echo "  macros               interactive shell with macros (no Distrobox)" >&2
}

env::_fail() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo "Error: ${message}" >&2
    env::_print_usage
    if [[ "${_ENV_SOURCED:-0}" == "1" ]]; then
        return 1
    fi
    exit 1
}

env::_invoke_backend() {
    local backend="$1"
    shift
    if [[ "${_ENV_SOURCED:-0}" == "1" ]]; then
        # shellcheck disable=SC1090
        source "$backend" "$@"
        return $?
    fi
    exec "$backend" "$@"
}

env::_exit_or_return() {
    if [[ "${_ENV_SOURCED:-0}" == "1" ]]; then
        return "$1"
    fi
    exit "$1"
}

case "$_mode" in
    macros)
        if [[ -n "${_runtime:-}" ]]; then
            env::_fail "mode 'macros' does not take extra arguments."
            env::_exit_or_return 1
        fi
        env::_invoke_backend "${_dir}/backends/run_macros.bash"
        ;;
    humble|jazzy)
        if [[ -z "${_runtime:-}" ]]; then
            # shellcheck disable=SC1091
            source "${_dir}/../include/platform.bash"
            if ! env::_require_native_linux_for_distrobox; then
                env::_exit_or_return 1
            fi
            exec "${_dir}/backends/run_distrobox.bash" "$_mode"
        fi
        if [[ "$_runtime" == "prod" ]]; then
            exec "${_dir}/backends/run_docker.bash" "$_mode" "$_runtime"
        fi
        env::_fail "unknown runtime '${_runtime}' (expected 'prod' or none)."
        env::_exit_or_return 1
        ;;
    "")
        env::_fail "missing mode."
        env::_exit_or_return 1
        ;;
    *)
        env::_fail "unknown mode '${_mode}'."
        env::_exit_or_return 1
        ;;
esac
