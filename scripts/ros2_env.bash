#!/usr/bin/bash

#
# Minimal ROS environment loaded in every container shell.
#
# Responsibilities:
# - Define workspace root (`ROS2_PROJECTS_WS_ROOT`).
# - Select ROS distro + domain defaults.
# - Source `/opt/ros/$ROS_DISTRO` if present.
# - Set CycloneDDS as default RMW and point it at `scripts/cyclone-dds.xml`.
# - Source `scripts/macros.bash` (helpers like `build`, `cbuild`, `diag`).
#

if [[ -n "${_ROS2_PROJECTS_WS_ENV_LOADED:-}" ]]; then
    return
fi
export _ROS2_PROJECTS_WS_ENV_LOADED=1

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROS2_PROJECTS_WS_ROOT="$(cd "$script_dir/.." && pwd)"

export ROS_DISTRO="${ROS_DISTRO:-humble}"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

# Prevent overlays from a different ROS distro leaking into this shell.
unset AMENT_PREFIX_PATH
unset CMAKE_PREFIX_PATH
unset COLCON_PREFIX_PATH

if [ -f "/opt/ros/$ROS_DISTRO/local_setup.bash" ]; then
    source "/opt/ros/$ROS_DISTRO/local_setup.bash"
fi

# Optional GUI over SSH: auto-select `DISPLAY` and `XAUTHORITY` for local X11 sockets.
# Disable with: `export ROS2_AUTO_LOCAL_DISPLAY=0`
_ros2_pick_xauthority() {
    local _cand
    shopt -s nullglob
    for _cand in \
        "${HOME}/.Xauthority" \
        "/run/user/$(id -u)/gdm/Xauthority" \
        "/run/user/$(id -u)/lightdm/xauthority" \
        "/var/lib/lightdm-data/${USER}/.Xauthority" \
        /run/user/"$(id -u)"/.mutter-Xwaylandauth.* \
        /run/user/"$(id -u)"/xauth_*
    do
        [[ -s "$_cand" ]] || continue
        export XAUTHORITY="$_cand"
        shopt -u nullglob
        return 0
    done
    shopt -u nullglob
    return 1
}

if [[ "${ROS2_AUTO_LOCAL_DISPLAY:-1}" != "0" ]]; then
    if [[ -z "${DISPLAY:-}" ]]; then
        for _ros2_xd in :0 :1; do
            _ros2_xsock="/tmp/.X11-unix/X${_ros2_xd#:}"
            if [[ -S "$_ros2_xsock" ]]; then
                export DISPLAY="${_ros2_xd}"
                [[ -n "${XAUTHORITY:-}" ]] || _ros2_pick_xauthority || true
                break
            fi
        done
        unset _ros2_xd _ros2_xsock
    elif [[ -z "${XAUTHORITY:-}" ]]; then
        case "${DISPLAY}" in
            :0|:1) _ros2_pick_xauthority || true ;;
        esac
    fi
fi
unset -f _ros2_pick_xauthority

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI="file://$ROS2_PROJECTS_WS_ROOT/scripts/cyclone-dds.xml"

if [ -f "$ROS2_PROJECTS_WS_ROOT/scripts/macros.bash" ]; then
    source "$ROS2_PROJECTS_WS_ROOT/scripts/macros.bash"
fi
