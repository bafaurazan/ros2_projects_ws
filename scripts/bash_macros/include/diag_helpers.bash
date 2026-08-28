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

_get_term_width() {
    local w="${COLUMNS:-}"
    if [[ -z "$w" ]] && command -v tput >/dev/null 2>&1; then
        w="$(tput cols 2>/dev/null || true)"
    fi
    [[ "$w" =~ ^[0-9]+$ ]] || w=72
    if (( w > 72 )); then
        w=72
    fi
    if (( w < 40 )); then
        w=40
    fi
    printf '%s\n' "$w"
}

_wrap_text() {
    local text="$1"
    local indent="$2"
    local width prefix
    width="$(_get_term_width)"
    width=$((width - indent))
    if (( width < 20 )); then
        width=20
    fi
    prefix="$(printf '%*s' "$indent" '')"
    if command -v fold >/dev/null 2>&1; then
        printf '%s\n' "$text" | fold -s -w "$width" | while IFS= read -r line || [[ -n "$line" ]]; do
            printf '%s%s\n' "$prefix" "$line"
        done
        return 0
    fi
    printf '%s%s\n' "$prefix" "$text"
}

_parse_macro_registry() {
    local launch_file="$1"
    local in_block=0
    local name=""
    local desc=""
    local line stripped

    [[ -f "$launch_file" ]] || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        stripped="${line#"${line%%[![:space:]]*}"}"
        if [[ "$stripped" == \#* ]]; then
            stripped="${stripped#\#}"
            stripped="${stripped# }"
        fi

        if [[ "$stripped" == "@macros-begin" ]]; then
            in_block=1
            continue
        fi
        if [[ "$stripped" == "@macros-end" ]]; then
            if [[ -n "$name" ]]; then
                printf '%s\t%s\n' "$name" "$desc"
            fi
            return 0
        fi
        [[ "$in_block" -eq 1 ]] || continue
        [[ -n "$stripped" ]] || continue

        if [[ "$stripped" == macro\ * ]]; then
            if [[ -n "$name" ]]; then
                printf '%s\t%s\n' "$name" "$desc"
            fi
            name="${stripped#macro }"
            name="${name%%[[:space:]]*}"
            desc=""
            continue
        fi

        if [[ -n "$name" ]]; then
            text="${stripped#"${stripped%%[![:space:]]*}"}"
            [[ -n "$text" ]] || continue
            if [[ -n "$desc" ]]; then
                desc+=" ${text}"
            else
                desc="$text"
            fi
        fi
    done < "$launch_file"

    if [[ -n "$name" ]]; then
        printf '%s\t%s\n' "$name" "$desc"
    fi
}

_print_macro_block() {
    local fn="$1"
    local description="$2"
    printf '  %s\n' "$fn"
    if [[ -n "$description" ]]; then
        _wrap_text "$description" 4
    else
        printf '    (no description)\n'
    fi
    echo
}

_print_macros() {
    echo "=== Macros ==="

    if [[ -z "${ROS2_PROJECTS_WS_ROOT:-}" ]]; then
        echo "ROS2_PROJECTS_WS_ROOT is not set. Run ./scripts/setup.bash first."
        return 0
    fi

    local src repo fn description
    local found=0
    local launch_file

    while IFS= read -r src; do
        [[ -n "$src" ]] || continue
        found=1
        repo="$(load::_get_repo_from_path "$src")"
        echo
        echo "[$repo]"
        launch_file="${src}/launch/macros.bash"
        while IFS=$'\t' read -r fn description; do
            [[ -n "$fn" ]] || continue
            if ! declare -F "$fn" >/dev/null 2>&1; then
                echo "diag: registry macro '${fn}' not defined in src/" >&2
            fi
            _print_macro_block "$fn" "$description"
        done < <(_parse_macro_registry "$launch_file")
    done < <(load::_find_sources "${ROS2_PROJECTS_WS_ROOT}")

    if [[ "$found" -eq 0 ]]; then
        echo "No scripts/bash_macros/ bundles found."
    fi
}
