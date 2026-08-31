#!/usr/bin/bash

# ROS 2 workspace context: distro, underlay, middleware, overlay prefix paths, cmake.

_get_workspace_root_from_include() {
    # scripts/bash_container/include → workspace root
    cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd
}

_set_workspace_root() {
    export ROS2_PROJECTS_WS_ROOT="$(_get_workspace_root_from_include)"
}

_set_default_ros2_context() {
    export ROS_DISTRO="${ROS_DISTRO:-humble}"
    export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
}

_reset_overlay_prefix_paths() {
    # Prevent overlays from a different ROS 2 distro leaking into this shell.
    unset AMENT_PREFIX_PATH
    unset CMAKE_PREFIX_PATH
    unset COLCON_PREFIX_PATH
}

_get_ros2_setup_path() {
    printf '%s\n' "/opt/ros/${ROS_DISTRO}/local_setup.bash"
}

_has_ros2_setup() {
    [[ -f "$(_get_ros2_setup_path)" ]]
}

_source_ros2_setup_when_available() {
    _has_ros2_setup || return 0
    # shellcheck disable=SC1090
    source "$(_get_ros2_setup_path)"
}

# Drop overlay entries that point at removed build_ws/install_* trees.
_prune_prefix_path() {
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

_sanitize_overlay_paths() {
    _prune_prefix_path COLCON_PREFIX_PATH
    _prune_prefix_path AMENT_PREFIX_PATH
    _prune_prefix_path CMAKE_PREFIX_PATH
}

_is_broken_local_cmake() {
    local cmake_bin="$1"
    [[ "$cmake_bin" == "${HOME}/.local/bin/cmake" ]] || return 1
    ! "$cmake_bin" --version >/dev/null 2>&1
}

_has_system_cmake() {
    [[ -x /usr/bin/cmake ]]
}

# pip's `cmake` package can install a broken console script in ~/.local/bin that
# shadows `/usr/bin/cmake` from the container and breaks colcon/ament builds.
_prefer_current_env_cmake() {
    _has_system_cmake || return 0

    export CMAKE_COMMAND=/usr/bin/cmake

    local cmake_bin
    cmake_bin="$(command -v cmake 2>/dev/null || true)"
    if _is_broken_local_cmake "$cmake_bin"; then
        export PATH="/usr/bin:$(echo "$PATH" | tr ':' '\n' | grep -vxF "${HOME}/.local/bin" | paste -sd: -)"
    elif [[ "$cmake_bin" != /usr/bin/cmake ]]; then
        export PATH="/usr/bin:${PATH}"
    fi
}

_get_cyclone_dds_config_path() {
    local include_dir config_dir
    include_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    config_dir="$(cd "${include_dir}/../config" && pwd)"
    printf '%s\n' "${config_dir}/cyclone-dds.xml"
}

_set_default_middleware() {
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export CYCLONEDDS_URI="file://$(_get_cyclone_dds_config_path)"
}

_init_ros2_env() {
    _set_workspace_root
    _set_default_ros2_context
    _reset_overlay_prefix_paths
    _source_ros2_setup_when_available
    _sanitize_overlay_paths
    _prefer_current_env_cmake
    _set_default_middleware
}
