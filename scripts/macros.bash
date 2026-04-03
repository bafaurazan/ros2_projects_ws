#!/usr/bin/bash

set -euo pipefail

build() {
    if [ ! -d "./src" ]; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    local ros_distro_name="${ROS_DISTRO:-humble}"
    local build_base="build_${ros_distro_name}"
    local install_base="install_${ros_distro_name}"
    local log_base="log_${ros_distro_name}"

    echo "Installing rosdep dependencies..."
    rosdep install --rosdistro "$ros_distro_name" --default-yes --ignore-packages-from-source --from-paths ./src

    echo "Installing additional APT dependencies..."
    while IFS= read -r apt_file; do
        [ -n "$apt_file" ] || continue
        while IFS= read -r apt_pkg; do
            apt_pkg="$(echo "$apt_pkg" | sed 's/\s*#.*$//g' | xargs)"
            [ -n "$apt_pkg" ] || continue
            sudo apt-get install -y "$apt_pkg"
        done < "$apt_file"
    done < <(find ./src -type f -name apt_packages.txt)

    echo "Installing additional PIP dependencies..."
    while IFS= read -r req_file; do
        [ -n "$req_file" ] || continue
        python3 -m pip install -r "$req_file"
    done < <(find ./src -type f -name requirements.txt)

    echo "Building packages..."
    local colcon_args=(
        "--log-base" "$log_base"
        "build"
        "--base-paths" "./src"
        "--build-base" "$build_base"
        "--install-base" "$install_base"
        "--symlink-install"
    )

    if [ "$#" -gt 0 ]; then
        colcon_args+=("--packages-select" "$@")
    fi

    colcon "${colcon_args[@]}"

    if [ -f "./${install_base}/local_setup.bash" ]; then
        source "./${install_base}/local_setup.bash"
    fi

    echo "Done."
}
