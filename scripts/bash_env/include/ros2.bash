#!/usr/bin/bash

# ROS 2 workspace context: distro, underlay, middleware, overlay prefix paths, cmake.

env::_get_workspace_root_from_include() {
    # scripts/bash_env/include → workspace root
    cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd
}

env::_set_workspace_root() {
    export ROS2_PROJECTS_WS_ROOT="$(env::_get_workspace_root_from_include)"
}

env::_set_default_ros2_context() {
    export ROS_DISTRO="${ROS_DISTRO:-humble}"
    export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
}

env::_reset_overlay_prefix_paths() {
    # Prevent overlays from a different ROS 2 distro leaking into this shell.
    unset AMENT_PREFIX_PATH
    unset CMAKE_PREFIX_PATH
    unset COLCON_PREFIX_PATH
}

env::_get_ros2_setup_path() {
    printf '%s\n' "/opt/ros/${ROS_DISTRO}/local_setup.bash"
}

env::_has_ros2_setup() {
    [[ -f "$(env::_get_ros2_setup_path)" ]]
}

env::_source_ros2_setup_when_available() {
    env::_has_ros2_setup || return 0
    # shellcheck disable=SC1090
    source "$(env::_get_ros2_setup_path)"
}

# Drop overlay entries that point at removed build_ws/install_* trees.
env::_prune_prefix_path() {
    local var_name="$1"
    local current="${!var_name:-}"
    [[ -n "$current" ]] || return 0

    local -a kept=()
    local entry
    local -a entries=()
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

env::_sanitize_overlay_paths() {
    env::_prune_prefix_path COLCON_PREFIX_PATH
    env::_prune_prefix_path AMENT_PREFIX_PATH
    env::_prune_prefix_path CMAKE_PREFIX_PATH
}

env::_is_broken_local_cmake() {
    local cmake_bin="$1"
    [[ "$cmake_bin" == "${HOME}/.local/bin/cmake" ]] || return 1
    ! "$cmake_bin" --version >/dev/null 2>&1
}

env::_has_system_cmake() {
    [[ -x /usr/bin/cmake ]]
}

# pip's `cmake` package can install a broken console script in ~/.local/bin that
# shadows `/usr/bin/cmake` from the container and breaks colcon/ament builds.
env::_prefer_current_env_cmake() {
    env::_has_system_cmake || return 0

    export CMAKE_COMMAND=/usr/bin/cmake

    local cmake_bin
    cmake_bin="$(command -v cmake 2>/dev/null || true)"
    if env::_is_broken_local_cmake "$cmake_bin"; then
        export PATH="/usr/bin:$(echo "$PATH" | tr ':' '\n' | grep -vxF "${HOME}/.local/bin" | paste -sd: -)"
    elif [[ "$cmake_bin" != /usr/bin/cmake ]]; then
        export PATH="/usr/bin:${PATH}"
    fi
}

env::_get_cyclone_dds_config_path() {
    local include_dir config_dir
    include_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    config_dir="$(cd "${include_dir}/../config" && pwd)"
    printf '%s\n' "${config_dir}/cyclone-dds.xml"
}

env::_set_default_middleware() {
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export CYCLONEDDS_URI="file://$(env::_get_cyclone_dds_config_path)"
}

env::_init_ros2_env() {
    env::_set_workspace_root
    env::_set_default_ros2_context
    env::_reset_overlay_prefix_paths
    env::_source_ros2_setup_when_available
    env::_sanitize_overlay_paths
    env::_prefer_current_env_cmake
    env::_set_default_middleware
}
