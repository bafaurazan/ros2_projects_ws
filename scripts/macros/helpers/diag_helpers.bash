#!/usr/bin/bash

# Private helpers for diag (short names). Bound to diag::_* via helpers_list.bash.

_has_command() {
    command -v "$1" >/dev/null 2>&1
}

_print_system() {
    echo "=== System ==="
    if _has_command lsb_release; then
        lsb_release -a 2>/dev/null || true
    elif [[ -f /etc/os-release ]]; then
        cat /etc/os-release
    else
        echo "No lsb_release or /etc/os-release available."
    fi
    echo "Kernel: $(uname -srmo)"
    echo
}

_print_tool() {
    local name="$1"
    if _has_command "$name"; then
        echo "${name}: $(command -v "$name")"
    else
        echo "${name}: not found"
    fi
}

_print_tools() {
    echo "=== Tools ==="
    _print_tool ros2
    _print_tool colcon
    _print_tool rosdep
    _print_tool cmake
    echo "CMAKE_COMMAND=${CMAKE_COMMAND:-<unset>}"
    echo
}

_print_environment() {
    echo "=== Environment ==="
    echo "ROS2_PROJECTS_WS_ROOT=${ROS2_PROJECTS_WS_ROOT:-<unset>}"
    echo "ROS_DISTRO=${ROS_DISTRO:-<unset>}"
    echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-<unset>}"
    echo "RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-<unset>}"
    echo "CYCLONEDDS_URI=${CYCLONEDDS_URI:-<unset>}"
    echo "_ENV_LOADED=${_ENV_LOADED:-<unset>}"
    echo
}

_get_expected_cyclone_uri() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]] || return 1
    printf '%s\n' "file://${ROS2_PROJECTS_WS_ROOT}/scripts/env/modules/cyclone-dds.xml"
}

_has_cyclone_xml() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" \
        && -f "${ROS2_PROJECTS_WS_ROOT}/scripts/env/modules/cyclone-dds.xml" ]]
}

_is_env_loaded() {
    [[ "${_ENV_LOADED:-}" == "1" ]]
}

_print_checks() {
    echo "=== Checks (env setup) ==="
    local ok=true
    local expected_rmw="rmw_cyclonedds_cpp"
    local expected_cyclone_uri=""
    expected_cyclone_uri="$(_get_expected_cyclone_uri 2>/dev/null || true)"

    if [[ "${RMW_IMPLEMENTATION:-}" == "$expected_rmw" ]]; then
        echo "[OK] RMW_IMPLEMENTATION is $expected_rmw"
    else
        echo "[FAIL] RMW_IMPLEMENTATION should be $expected_rmw"
        ok=false
    fi

    if [[ -n "$expected_cyclone_uri" && "${CYCLONEDDS_URI:-}" == "$expected_cyclone_uri" ]]; then
        echo "[OK] CYCLONEDDS_URI matches workspace path"
    else
        echo "[FAIL] CYCLONEDDS_URI does not match expected workspace path"
        ok=false
    fi

    if _has_cyclone_xml; then
        echo "[OK] cyclone-dds.xml exists"
    else
        echo "[FAIL] cyclone-dds.xml missing"
        ok=false
    fi

    if _is_env_loaded; then
        echo "[OK] env setup load marker is set"
    else
        echo "[FAIL] env setup load marker is not set"
        ok=false
    fi

    if _has_command cmake && cmake --version >/dev/null 2>&1; then
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
    [[ "$ok" == true ]]
}

_get_macros_index() {
    printf '%s\n' "${ROS2_PROJECTS_WS_ROOT:-}/build_ws/macros/macros_index"
}

_has_macros_index() {
    local index_file
    index_file="$(_get_macros_index)"
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" && -f "$index_file" ]]
}

_print_macros() {
    echo "=== Available macros ==="
    local index_file
    index_file="$(_get_macros_index)"

    if ! _has_macros_index; then
        echo "No macros_index yet. Run sync_macros (or open a new shell)."
        return 0
    fi

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
}
