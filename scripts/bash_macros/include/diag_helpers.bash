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
    printf '%s\n' "file://${ROS2_PROJECTS_WS_ROOT}/scripts/bash_container/config/cyclone-dds.xml"
}

_has_cyclone_xml() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" \
        && -f "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_container/config/cyclone-dds.xml" ]]
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

_extract_function_description() {
    local file="$1"
    local fn="$2"
    local line stripped text
    local -a comments=()
    local in_comment_block=0
    local found=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        stripped="${line#"${line%%[![:space:]]*}"}"

        if [[ "$stripped" == \#!* ]]; then
            comments=()
            in_comment_block=0
            continue
        fi

        if [[ "$stripped" == \#* ]]; then
            if [[ "$in_comment_block" -eq 0 ]]; then
                comments=()
                in_comment_block=1
            fi
            text="${stripped#\#}"
            text="${text# }"
            comments+=("$text")
            continue
        fi

        if [[ -z "$stripped" ]]; then
            in_comment_block=0
            continue
        fi

        in_comment_block=0
        if [[ "$stripped" =~ ^(function[[:space:]]+)?${fn}[[:space:]]*\(\) ]]; then
            found=1
            break
        fi
        comments=()
    done < "$file"

    if [[ "$found" -eq 1 && ${#comments[@]} -gt 0 ]]; then
        local candidate
        for candidate in "${comments[@]}"; do
            [[ -z "$candidate" ]] && continue
            [[ "$candidate" == Usage:* ]] && continue
            printf '%s\n' "$candidate"
            return 0
        done
        candidate="${comments[0]}"
        candidate="${candidate#Usage:}"
        candidate="${candidate# }"
        printf '%s\n' "$candidate"
        return 0
    fi

    while IFS= read -r line; do
        stripped="${line#"${line%%[![:space:]]*}"}"
        [[ "$stripped" == \#!* ]] && continue
        if [[ "$stripped" == \#* ]]; then
            text="${stripped#\#}"
            text="${text# }"
            [[ -n "$text" ]] || continue
            printf '%s\n' "$text"
            return 0
        fi
        [[ -n "$stripped" ]] && break
    done < "$file"
}

_print_macros() {
    echo "=== Available macros ==="

    if [[ -z "${ROS2_PROJECTS_WS_ROOT:-}" ]]; then
        echo "ROS2_PROJECTS_WS_ROOT is not set. Run ./scripts/setup.bash first."
        return 0
    fi

    local src repo file fn description
    local found=0

    while IFS= read -r src; do
        [[ -n "$src" ]] || continue
        found=1
        repo="$(load::_get_repo_from_path "$src")"
        echo
        echo "[$repo]  $src"
        while IFS= read -r file; do
            [[ -n "$file" ]] || continue
            while IFS= read -r fn; do
                [[ -n "$fn" ]] || continue
                description="$(diag::_extract_function_description "$file" "$fn")"
                if [[ -n "$description" ]]; then
                    printf '  %-16s  %s\n' "$fn" "$description"
                else
                    printf '  %-16s  (%s)\n' "$fn" "$(basename "$file")"
                fi
            done < <(load::_extract_functions "$file")
        done < <(load::_list_api_files "$src")
    done < <(load::_find_sources "${ROS2_PROJECTS_WS_ROOT}")

    if [[ "$found" -eq 0 ]]; then
        echo "No scripts/bash_macros/ bundles found."
    fi
}
