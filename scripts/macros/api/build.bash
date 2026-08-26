#!/usr/bin/bash

# Install workspace dependencies (rosdep + apt_packages.txt + requirements.txt), then `cbuild`.
# Usage: build [colcon build args...]

_macros_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${_macros_dir}/helpers/helpers_list.bash"
unset _macros_dir

build() {
    if ! build::_has_src_dir; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    local ros2_distro_name
    ros2_distro_name="$(build::_get_ros_distro)"

    echo "Updating rosdep index..."
    rosdep update --rosdistro "$ros2_distro_name"

    echo "Installing rosdep dependencies..."
    local -a rosdep_paths=()
    mapfile -t rosdep_paths < <(build::_collect_rosdep_paths)
    rosdep install --rosdistro "$ros2_distro_name" --default-yes \
        --ignore-packages-from-source -r --from-paths "${rosdep_paths[@]}"

    echo "Installing additional APT dependencies..."
    build::_install_apt_packages

    # Install into $VIRTUAL_ENV / ./.venv / ./venv when present. Otherwise use system python3;
    # on Ubuntu 24.04+ (e.g. Jazzy) system pip blocks installs (PEP 668), so add --break-system-packages.
    echo "Installing additional PIP dependencies..."
    build::_install_pip_requirements

    echo "Building packages..."
    cbuild "$@"
}

# Distro-aware `colcon build`: writes to ./build_ws/build_<ROS_DISTRO>/, install_*/, log_*/, then sources install.
# Usage: cbuild [colcon build args...]
cbuild() {
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

    sanitize_overlay_paths
    prefer_current_env_cmake

    colcon --log-base "$log_base" build \
        --base-paths "./src" \
        --build-base "$build_base" \
        --install-base "$install_base" \
        "$@"

    build::_source_install_overlay "$install_base"
    echo "Done."
}
