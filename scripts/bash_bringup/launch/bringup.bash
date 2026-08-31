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

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    _BRINGUP_SOURCED=1
else
    _BRINGUP_SOURCED=0
fi

# shellcheck disable=SC1091
source "${_bringup_dir}/../include/bringup_helpers.bash"
# shellcheck disable=SC1091
source "${_bringup_dir}/../src/dispatch.bash"
unset _bringup_dir

_dispatch
