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

# Drop overlay entries that point at removed build_ws/install_* trees.
_ros2_prune_prefix_path() {
    local var_name="$1"
    local current="${!var_name:-}"
    [[ -n "$current" ]] || return 0

    local -a kept=()
    local entry
    IFS=':' read -ra entries <<< "$current"
    for entry in "${entries[@]}"; do
        [[ -n "$entry" && -d "$entry" ]] && kept+=("$entry")
    done

    if ((${#kept[@]})); then
        printf -v "$var_name" '%s' "${kept[0]}"
        local i
        for ((i = 1; i < ${#kept[@]}; ++i)); do
            printf -v "$var_name" '%s:%s' "${!var_name}" "${kept[$i]}"
        done
        export "$var_name"
    else
        unset "$var_name"
    fi
}

_ros2_sanitize_overlay_paths() {
    _ros2_prune_prefix_path COLCON_PREFIX_PATH
    _ros2_prune_prefix_path AMENT_PREFIX_PATH
    _ros2_prune_prefix_path CMAKE_PREFIX_PATH
}

# pip's `cmake` package can install a broken console script in ~/.local/bin that
# shadows the system binary and breaks colcon/ament builds.
_ros2_prefer_system_cmake() {
    [[ -x /usr/bin/cmake ]] || return 0

    export CMAKE_COMMAND=/usr/bin/cmake

    local cmake_bin
    cmake_bin="$(command -v cmake 2>/dev/null || true)"
    if [[ "$cmake_bin" == "${HOME}/.local/bin/cmake" ]] && ! "$cmake_bin" --version >/dev/null 2>&1; then
        export PATH="/usr/bin:$(echo "$PATH" | tr ':' '\n' | grep -vxF "${HOME}/.local/bin" | paste -sd: -)"
    elif [[ "$cmake_bin" != /usr/bin/cmake ]]; then
        export PATH="/usr/bin:${PATH}"
    fi
}

_ros2_sanitize_overlay_paths
_ros2_prefer_system_cmake

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
