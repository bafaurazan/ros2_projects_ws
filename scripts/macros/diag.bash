#!/usr/bin/bash

# Print system/tools/env info, verify env setup settings, and list available macros.
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
    echo "_ENV_LOADED=${_ENV_LOADED:-<unset>}"
    echo

    echo "=== Checks (env setup) ==="
    local ok=true
    local expected_rmw="rmw_cyclonedds_cpp"
    local expected_cyclone_uri=""
    if [ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]; then
        expected_cyclone_uri="file://${ROS2_PROJECTS_WS_ROOT}/scripts/env/modules/cyclone-dds.xml"
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

    if [ -n "${ROS2_PROJECTS_WS_ROOT:-}" ] && [ -f "${ROS2_PROJECTS_WS_ROOT}/scripts/env/modules/cyclone-dds.xml" ]; then
        echo "[OK] cyclone-dds.xml exists"
    else
        echo "[FAIL] cyclone-dds.xml missing"
        ok=false
    fi

    if [ "${_ENV_LOADED:-}" = "1" ]; then
        echo "[OK] env setup load marker is set"
    else
        echo "[FAIL] env setup load marker is not set"
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

    echo
    echo "=== Available macros ==="
    local index_file="${ROS2_PROJECTS_WS_ROOT:-}/build_ws/macros/macros_index"
    if [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" && -f "$index_file" ]]; then
        local repo source_dir file fn last_repo=""
        while IFS=$'\t' read -r repo source_dir file fn; do
            [[ "$repo" == \#* || -z "$repo" ]] && continue
            if [[ "$repo" != "$last_repo" ]]; then
                echo
                echo "[$repo]  $source_dir  ->  ${ROS2_PROJECTS_WS_ROOT}/build_ws/macros/${repo}/"
                last_repo="$repo"
            fi
            echo "  $fn  ($file)"
        done < "$index_file"
    else
        echo "No macros_index yet. Run sync_macros (or open a new shell)."
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
