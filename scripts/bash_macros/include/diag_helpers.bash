#!/usr/bin/bash

# Private helpers for diag. Bodies are diag::_*.

diag::_has_command() {
    command -v "$1" >/dev/null 2>&1
}

diag::_print_system() {
    echo "=== System ==="
    if diag::_has_command lsb_release; then
        lsb_release -a 2>/dev/null || true
    elif [[ -f /etc/os-release ]]; then
        cat /etc/os-release
    else
        echo "No lsb_release or /etc/os-release available."
    fi
    echo "Kernel: $(uname -srmo)"
    echo
}

diag::_print_tool() {
    local name="$1"
    if diag::_has_command "$name"; then
        echo "${name}: $(command -v "$name")"
    else
        echo "${name}: not found"
    fi
}

diag::_print_tools() {
    echo "=== Tools ==="
    diag::_print_tool ros2
    diag::_print_tool colcon
    diag::_print_tool rosdep
    diag::_print_tool cmake
    echo "CMAKE_COMMAND=${CMAKE_COMMAND:-<unset>}"
    echo
}

diag::_print_environment() {
    echo "=== Environment ==="
    echo "ROS2_PROJECTS_WS_ROOT=${ROS2_PROJECTS_WS_ROOT:-<unset>}"
    echo "ROS_DISTRO=${ROS_DISTRO:-<unset>}"
    echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-<unset>}"
    echo "RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-<unset>}"
    echo "CYCLONEDDS_URI=${CYCLONEDDS_URI:-<unset>}"
    echo "_ENV_LOADED=${_ENV_LOADED:-<unset>}"
    diag::_print_github_hosts
    echo
}

diag::_print_github_hosts() {
    local hosts_csv="" host
    while IFS= read -r host; do
        [[ -n "$host" ]] || continue
        if [[ -n "$hosts_csv" ]]; then
            hosts_csv+=", ${host}"
        else
            hosts_csv="$host"
        fi
    done < <(importer::_get_github_hosts)

    if [[ -f "${HOME}/.ssh/config" ]]; then
        echo "importer github hosts: ${hosts_csv} (from ~/.ssh/config)"
    else
        echo "importer github hosts: ${hosts_csv} (default; no ~/.ssh/config)"
    fi
}

diag::_get_expected_cyclone_uri() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]] || return 1
    printf '%s\n' "file://${ROS2_PROJECTS_WS_ROOT}/scripts/bash_env/config/cyclone-dds.xml"
}

diag::_has_cyclone_xml() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" \
        && -f "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_env/config/cyclone-dds.xml" ]]
}

diag::_is_env_loaded() {
    [[ "${_ENV_LOADED:-}" == "1" ]]
}

diag::_is_macros_loaded() {
    [[ -n "${_MACROS_LOADED:-}" ]]
}

diag::_print_checks() {
    echo "=== Checks (env setup) ==="
    local ok=true
    local expected_rmw="rmw_cyclonedds_cpp"
    local expected_cyclone_uri=""
    expected_cyclone_uri="$(diag::_get_expected_cyclone_uri 2>/dev/null || true)"

    if diag::_is_env_loaded; then
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

        if diag::_has_cyclone_xml; then
            echo "[OK] cyclone-dds.xml exists"
        else
            echo "[FAIL] cyclone-dds.xml missing"
            ok=false
        fi

        echo "[OK] env setup load marker is set"

        if diag::_has_command cmake && cmake --version >/dev/null 2>&1; then
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
    elif diag::_is_macros_loaded; then
        echo "[OK] macros session load marker is set"
        echo "[SKIP] RMW_IMPLEMENTATION (macros-only session)"
        echo "[SKIP] CYCLONEDDS_URI (macros-only session)"
        if diag::_has_cyclone_xml; then
            echo "[OK] cyclone-dds.xml exists"
        else
            echo "[SKIP] cyclone-dds.xml missing (macros-only session)"
        fi
        echo "[SKIP] env setup load marker (macros-only session)"
        echo "[SKIP] cmake / CMAKE_COMMAND (macros-only session)"
    else
        echo "[FAIL] neither env setup nor macros session load marker is set"
        ok=false
    fi

    echo
    [[ "$ok" == true ]]
}
diag::_get_terminal_width() {
    local width="${COLUMNS:-}"
    if [[ -z "$width" ]] && command -v tput >/dev/null 2>&1; then
        width="$(tput cols 2>/dev/null || true)"
    fi
    [[ "$width" =~ ^[0-9]+$ ]] || width=72
    if (( width > 72 )); then
        width=72
    fi
    if (( width < 40 )); then
        width=40
    fi
    printf '%s\n' "$width"
}

diag::_wrap_text() {
    local text="$1"
    local indent="$2"
    local width prefix
    width="$(diag::_get_terminal_width)"
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

diag::_parse_macro_registry() {
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

diag::_print_macro_block() {
    local fn="$1"
    local description="$2"
    printf '  %s\n' "$fn"
    if [[ -n "$description" ]]; then
        diag::_wrap_text "$description" 4
    else
        printf '    (no description)\n'
    fi
    echo
}

diag::_print_macros() {
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
            diag::_print_macro_block "$fn" "$description"
        done < <(diag::_parse_macro_registry "$launch_file")
    done < <(load::_find_sources "${ROS2_PROJECTS_WS_ROOT}")

    if [[ "$found" -eq 0 ]]; then
        echo "No scripts/bash_macros/ bundles found."
    fi
}
