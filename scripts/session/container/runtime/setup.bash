#!/usr/bin/env bash

#
# Runtime dispatcher (host): Distrobox today, Docker when `prod` is implemented.
#
# Usage:
#   ./scripts/setup.bash humble|jazzy
#   ./scripts/setup.bash humble|jazzy prod
#

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_mode="${1:-}"
_runtime="${2:-}"

_print_usage() {
    echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]" >&2
    echo "  humble | jazzy       Distrobox runtime" >&2
    echo "  humble | jazzy prod  production runtime (not implemented yet)" >&2
}

if [[ "$_mode" != "humble" && "$_mode" != "jazzy" ]]; then
    echo "Error: unknown distro '${_mode}'." >&2
    _print_usage
    exit 1
fi

if [[ -z "$_runtime" ]]; then
    exec "${_dir}/distrobox/setup.bash" "$_mode"
fi

if [[ "$_runtime" == "prod" ]]; then
    exec "${_dir}/docker/setup.bash" "$_mode" "$_runtime"
fi

echo "Error: unknown runtime '${_runtime}' (expected 'prod' or none)." >&2
_print_usage
exit 1
