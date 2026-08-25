#!/usr/bin/bash

#
# Container shell bootstrap (sourced from ~/.bashrc via Distrobox).
#
# Loads ROS 2, optional local display, then macros from
# $ROS2_PROJECTS_WS_ROOT/build_ws/macros/.
#

if [[ -n "${_ENV_LOADED:-}" ]]; then
    return
fi
export _ENV_LOADED=1

_env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${_env_dir}/modules/ros2.bash"
source "${_env_dir}/modules/display.bash"

init_ros2_env
set_local_display_if_available
unset -f set_xauthority_from_local_candidates

# shellcheck disable=SC1091
source "${ROS2_PROJECTS_WS_ROOT}/scripts/macros/sync.bash"
sync_macros
unset _env_dir
