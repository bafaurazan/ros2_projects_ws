#!/usr/bin/bash

# ROS 2 workspace context: distro, underlay, middleware, overlay prefix paths, cmake.

set_workspace_root() {
    export ROS2_PROJECTS_WS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
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

sanitize_overlay_paths() {
    prune_prefix_path COLCON_PREFIX_PATH
    prune_prefix_path AMENT_PREFIX_PATH
    prune_prefix_path CMAKE_PREFIX_PATH
}

# pip's `cmake` package can install a broken console script in ~/.local/bin that
# shadows `/usr/bin/cmake` from the container and breaks colcon/ament builds.
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

set_default_middleware() {
    local _env_config_dir
    _env_config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export CYCLONEDDS_URI="file://${_env_config_dir}/cyclone-dds.xml"
}

init_ros2_env() {
    set_workspace_root
    set_default_ros2_context
    reset_overlay_prefix_paths
    source_ros2_setup_if_available
    sanitize_overlay_paths
    prefer_current_env_cmake
    set_default_middleware
}
