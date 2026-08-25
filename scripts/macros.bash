#!/usr/bin/bash

#
# ROS2 Projects workspace helpers.
#
# Sourced by `scripts/ros2_env.bash` inside the container shell.
#
# Macros:
# - `build [colcon args...]` — install deps (rosdep/apt/pip), then run `cbuild`.
# - `cbuild [colcon args...]` — `colcon build` into ./build_ws/{build,install,log}_<ROS_DISTRO>/.
# - `diag` — print env/tool sanity checks (RMW, CycloneDDS, cmake, paths).
#

# Install workspace dependencies (rosdep + apt_packages.txt + requirements.txt), then `cbuild`.
# Usage: build [colcon build args...]
build() {
    if [ ! -d "./src" ]; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    local ros2_distro_name="${ROS_DISTRO:-humble}"

    echo "Updating rosdep index..."
    rosdep update --rosdistro "$ros2_distro_name"

    echo "Installing rosdep dependencies..."
    local rosdep_paths=(./src)
    declare -A _rosdep_seen=()
    _rosdep_seen["./src"]=1
    local d
    while IFS= read -r -d '' d; do
        shopt -s nullglob
        local -a _nested_pkgs=( "$d"/*/package.xml )
        shopt -u nullglob
        ((${#_nested_pkgs[@]} >= 2)) || continue
        [[ -n ${_rosdep_seen[$d]:-} ]] && continue
        _rosdep_seen[$d]=1
        rosdep_paths+=("$d")
    done < <(find ./src -type d -print0)

    rosdep install --rosdistro "$ros2_distro_name" --default-yes \
        --ignore-packages-from-source -r --from-paths "${rosdep_paths[@]}"

    echo "Installing additional APT dependencies..."
    while IFS= read -r apt_file; do
        [ -n "$apt_file" ] || continue
        while IFS= read -r apt_pkg; do
            apt_pkg="$(echo "$apt_pkg" | sed 's/\s*#.*$//g' | xargs)"
            [ -n "$apt_pkg" ] || continue
            sudo apt-get install -y "$apt_pkg"
        done < "$apt_file"
    done < <(find ./src -type f -name apt_packages.txt)

    # Install into $VIRTUAL_ENV / ./.venv / ./venv when present. Otherwise use system python3;
    # on Ubuntu 24.04+ (e.g. Jazzy) system pip blocks installs (PEP 668), so add --break-system-packages.
    echo "Installing additional PIP dependencies..."
    local pip_python=""
    local using_venv=0
    if [[ -n "${VIRTUAL_ENV:-}" && -x "${VIRTUAL_ENV}/bin/python" ]]; then
        pip_python="${VIRTUAL_ENV}/bin/python"
        using_venv=1
    elif [[ -x "./.venv/bin/python" ]]; then
        pip_python="$(pwd)/.venv/bin/python"
        using_venv=1
    elif [[ -x "./venv/bin/python" ]]; then
        pip_python="$(pwd)/venv/bin/python"
        using_venv=1
    else
        pip_python="$(command -v python3)"
    fi

    local pip_args=(-r)
    if [ "$using_venv" -eq 1 ]; then
        echo "PIP target: venv ($pip_python)"
    else
        local py_stdlib
        py_stdlib="$("$pip_python" -c 'import sysconfig; print(sysconfig.get_path("stdlib"))' 2>/dev/null || true)"
        if [[ -n "$py_stdlib" && -f "${py_stdlib}/EXTERNALLY-MANAGED" ]]; then
            pip_args=(--break-system-packages -r)
        fi
        echo "PIP target: system Python ($pip_python)"
    fi

    while IFS= read -r req_file; do
        [ -n "$req_file" ] || continue
        "$pip_python" -m pip install "${pip_args[@]}" "$req_file"
    done < <(find ./src -type f -name requirements.txt)

    echo "Building packages..."
    cbuild "$@"
}

# Runs `colcon build` into ./build_ws/build_<ROS_DISTRO>/, install_*/, log_*/, then sources install.
# Usage: cbuild [colcon build args...]
cbuild() {
    if [ ! -d "./src" ]; then
        echo "Missing ./src in current directory: $(pwd)"
        return 1
    fi

    local ros2_distro_name="${ROS_DISTRO:-humble}"
    local workspace_artifacts_dir="build_ws"
    local build_base="${workspace_artifacts_dir}/build_${ros2_distro_name}"
    local install_base="${workspace_artifacts_dir}/install_${ros2_distro_name}"
    local log_base="${workspace_artifacts_dir}/log_${ros2_distro_name}"

    mkdir -p "$workspace_artifacts_dir"

    sanitize_overlay_paths
    prefer_current_env_cmake

    colcon --log-base "$log_base" build \
        --base-paths "./src" \
        --build-base "$build_base" \
        --install-base "$install_base" \
        --symlink-install \
        "$@"

    if [ -f "./${install_base}/local_setup.bash" ]; then
        # Overlay this workspace only (ROS already sourced). Drop set -u for source — ament reads unset variables.
        local had_nounset=0
        if [[ $- == *u* ]]; then
            had_nounset=1
            set +u
        fi
        source "./${install_base}/local_setup.bash"
        if [ "$had_nounset" -eq 1 ]; then
            set -u
        fi
    fi

    echo "Done."
}

# Print system/tools/env info and verify ros2_env.bash settings (RMW, CycloneDDS, cmake).
diag() {
    echo "=== System ==="
    if command -v lsb_release >/dev/null 2>&1; then
        lsb_release -a 2>/dev/null || true
    elif [ -f /etc/os-release ]; then
        cat /etc/os-release
    else
        echo "No lsb_release or /etc/os-release available."
    fi
    echo "Kernel: $(uname -srmo)"
    echo

    echo "=== Tools ==="
    command -v ros2 >/dev/null 2>&1 && echo "ros2: $(command -v ros2)" || echo "ros2: not found"
    command -v colcon >/dev/null 2>&1 && echo "colcon: $(command -v colcon)" || echo "colcon: not found"
    command -v rosdep >/dev/null 2>&1 && echo "rosdep: $(command -v rosdep)" || echo "rosdep: not found"
    command -v cmake >/dev/null 2>&1 && echo "cmake: $(command -v cmake)" || echo "cmake: not found"
    echo "CMAKE_COMMAND=${CMAKE_COMMAND:-<unset>}"
    echo

    echo "=== Environment ==="
    echo "ROS2_PROJECTS_WS_ROOT=${ROS2_PROJECTS_WS_ROOT:-<unset>}"
    echo "ROS_DISTRO=${ROS_DISTRO:-<unset>}"
    echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-<unset>}"
    echo "RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-<unset>}"
    echo "CYCLONEDDS_URI=${CYCLONEDDS_URI:-<unset>}"
    echo "_ROS2_PROJECTS_WS_ENV_LOADED=${_ROS2_PROJECTS_WS_ENV_LOADED:-<unset>}"
    echo

    echo "=== Checks (ros2_env.bash) ==="
    local ok=true
    local expected_rmw="rmw_cyclonedds_cpp"
    local expected_cyclone_uri=""
    if [ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]; then
        expected_cyclone_uri="file://${ROS2_PROJECTS_WS_ROOT}/scripts/cyclone-dds.xml"
    fi

    if [ "${RMW_IMPLEMENTATION:-}" = "$expected_rmw" ]; then
        echo "[OK] RMW_IMPLEMENTATION is $expected_rmw"
    else
        echo "[FAIL] RMW_IMPLEMENTATION should be $expected_rmw"
        ok=false
    fi

    if [ -n "$expected_cyclone_uri" ] && [ "${CYCLONEDDS_URI:-}" = "$expected_cyclone_uri" ]; then
        echo "[OK] CYCLONEDDS_URI matches workspace path"
    else
        echo "[FAIL] CYCLONEDDS_URI does not match expected workspace path"
        ok=false
    fi

    if [ -n "${ROS2_PROJECTS_WS_ROOT:-}" ] && [ -f "${ROS2_PROJECTS_WS_ROOT}/scripts/cyclone-dds.xml" ]; then
        echo "[OK] cyclone-dds.xml exists"
    else
        echo "[FAIL] cyclone-dds.xml missing"
        ok=false
    fi

    if [ "${_ROS2_PROJECTS_WS_ENV_LOADED:-}" = "1" ]; then
        echo "[OK] ros2_env.bash load marker is set"
    else
        echo "[FAIL] ros2_env.bash load marker is not set"
        ok=false
    fi

    if command -v cmake >/dev/null 2>&1 && cmake --version >/dev/null 2>&1; then
        echo "[OK] cmake works ($(command -v cmake))"
    else
        echo "[FAIL] cmake is missing or broken"
        ok=false
    fi

    if [[ "${CMAKE_COMMAND:-}" == /usr/bin/cmake ]]; then
        echo "[OK] CMAKE_COMMAND points to system cmake"
    elif [[ -x /usr/bin/cmake ]]; then
        echo "[FAIL] CMAKE_COMMAND should be /usr/bin/cmake"
        ok=false
    fi

    if [ "$ok" = true ]; then
        echo
        echo "Diagnostic status: OK"
    else
        echo
        echo "Diagnostic status: FAIL"
        return 1
    fi
}
