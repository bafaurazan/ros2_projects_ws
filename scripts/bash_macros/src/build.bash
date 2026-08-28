#!/usr/bin/bash

# Usage: build [colcon build args...]

_macros_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${_macros_dir}/include/helpers_list.bash"
unset _macros_dir

build() {
    build::_require_ros_toolchain build || return 1

    if ! build::_has_src_dir; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    local ros2_distro_name
    ros2_distro_name="$(build::_get_ros_distro)"

    echo "Updating rosdep index..."
    rosdep update --rosdistro "$ros2_distro_name" || return 1

    echo "Installing rosdep dependencies..."
    local -a rosdep_paths=()
    mapfile -t rosdep_paths < <(build::_collect_rosdep_paths)
    rosdep install --rosdistro "$ros2_distro_name" --default-yes \
        --ignore-packages-from-source -r --from-paths "${rosdep_paths[@]}" || return 1

    echo "Installing additional APT dependencies..."
    build::_install_apt_packages || return 1

    echo "Installing additional PIP dependencies..."
    build::_install_pip_requirements || return 1

    echo "Building packages..."
    cbuild "$@"
}

# Usage: cbuild [colcon build args...]
cbuild() {
    build::_require_ros_toolchain cbuild || return 1

    if ! build::_has_src_dir; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    if declare -F load_macros >/dev/null 2>&1; then
        load_macros || return 1
    fi

    local ros2_distro_name workspace_artifacts_dir build_base install_base log_base
    ros2_distro_name="$(build::_get_ros_distro)"
    workspace_artifacts_dir="$(build::_get_artifacts_dir)"
    build_base="${workspace_artifacts_dir}/build_${ros2_distro_name}"
    install_base="${workspace_artifacts_dir}/install_${ros2_distro_name}"
    log_base="${workspace_artifacts_dir}/log_${ros2_distro_name}"

    mkdir -p "$workspace_artifacts_dir"

    if declare -F sanitize_overlay_paths >/dev/null 2>&1; then
        sanitize_overlay_paths
    fi
    if declare -F prefer_current_env_cmake >/dev/null 2>&1; then
        prefer_current_env_cmake
    fi

    colcon --log-base "$log_base" build \
        --base-paths "./src" \
        --build-base "$build_base" \
        --install-base "$install_base" \
        "$@"
    local colcon_status=$?
    if [[ "$colcon_status" -ne 0 ]]; then
        echo "colcon build failed (exit ${colcon_status}). Install overlay not sourced." >&2
        return "$colcon_status"
    fi

    build::_source_install_overlay "$install_base"
    echo "Done."
}
