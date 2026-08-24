#!/usr/bin/bash

#
# Minimal ROS 2 environment loaded in every container shell.
#
# Responsibilities:
# - Define workspace root (`ROS2_PROJECTS_WS_ROOT`).
# - Select ROS 2 distro + domain defaults.
# - Source `/opt/ros/$ROS_DISTRO` if present.
# - Set CycloneDDS as default RMW and point it at `scripts/cyclone-dds.xml`.
# - Source `scripts/macros.bash` (helpers like `build`, `cbuild`, `diag`).
#

if [[ -n "${_ROS2_PROJECTS_WS_ENV_LOADED:-}" ]]; then
    return
fi
export _ROS2_PROJECTS_WS_ENV_LOADED=1

# -----------------------------------------------------------------------------
# Workspace and ROS 2 environment bootstrap.
# -----------------------------------------------------------------------------
set_workspace_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export ROS2_PROJECTS_WS_ROOT="$(cd "$script_dir/.." && pwd)"
}

set_default_ros2_context() {
    export ROS_DISTRO="${ROS_DISTRO:-humble}"
    export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
}

reset_overlay_prefix_paths() {
    # Prevent overlays from a different ROS 2 distro leaking into this shell.
    unset AMENT_PREFIX_PATH
    unset CMAKE_PREFIX_PATH
    unset COLCON_PREFIX_PATH
}

source_ros2_setup_if_available() {
    local ros2_setup_path="/opt/ros/$ROS_DISTRO/local_setup.bash"
    if [[ -f "$ros2_setup_path" ]]; then
        source "$ros2_setup_path"
    fi
}

# -----------------------------------------------------------------------------
# Path sanitization and tool selection.
# -----------------------------------------------------------------------------
# Drop overlay entries that point at removed build_ws/install_* trees.
prune_prefix_path() {
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

# Remove dead overlay entries from ROS 2-related prefix paths so deleted build or
# install trees do not keep leaking into future shells or builds.
sanitize_overlay_paths() {
    prune_prefix_path COLCON_PREFIX_PATH
    prune_prefix_path AMENT_PREFIX_PATH
    prune_prefix_path CMAKE_PREFIX_PATH
}

# pip's `cmake` package can install a broken console script in ~/.local/bin that
# shadows the `/usr/bin/cmake` from the current environment (for example a
# distrobox/container) and breaks colcon/ament builds.
prefer_current_env_cmake() {
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

# -----------------------------------------------------------------------------
# Local GUI/X11 autodetection.
# -----------------------------------------------------------------------------
# Optional GUI over SSH: auto-select `DISPLAY` and `XAUTHORITY` for local X11 sockets.
# Disable with: `export ROS2_AUTO_LOCAL_DISPLAY=0`
set_xauthority_from_local_candidates() {
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

set_local_display_if_available() {
    local display_candidate
    local x_socket

    [[ "${ROS2_AUTO_LOCAL_DISPLAY:-1}" != "0" ]] || return 0

    if [[ -z "${DISPLAY:-}" ]]; then
        for display_candidate in :0 :1; do
            x_socket="/tmp/.X11-unix/X${display_candidate#:}"
            if [[ -S "$x_socket" ]]; then
                export DISPLAY="${display_candidate}"
                [[ -n "${XAUTHORITY:-}" ]] || set_xauthority_from_local_candidates || true
                return 0
            fi
        done
        return 0
    fi

    if [[ -z "${XAUTHORITY:-}" ]]; then
        case "${DISPLAY}" in
            :0|:1) set_xauthority_from_local_candidates || true ;;
        esac
    fi
}

# -----------------------------------------------------------------------------
# ROS 2 middleware and helper loading.
# -----------------------------------------------------------------------------
set_default_middleware() {
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export CYCLONEDDS_URI="file://$ROS2_PROJECTS_WS_ROOT/scripts/cyclone-dds.xml"
}

source_workspace_macros_if_available() {
    local macros_path="$ROS2_PROJECTS_WS_ROOT/scripts/macros.bash"
    if [[ -f "$macros_path" ]]; then
        source "$macros_path"
    fi
}

init_environment() {
    set_workspace_root
    set_default_ros2_context
    reset_overlay_prefix_paths
    source_ros2_setup_if_available
    sanitize_overlay_paths
    prefer_current_env_cmake
    set_local_display_if_available
    set_default_middleware
    source_workspace_macros_if_available
}

init_environment

unset -f set_xauthority_from_local_candidates
