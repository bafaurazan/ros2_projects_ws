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
_bringup="${_dir}/bash_bringup/launch/bringup.bash"
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # shellcheck disable=SC1090
    source "$_bringup" "$@"
    return $?
fi
exec "$_bringup" "$@"
