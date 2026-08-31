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
