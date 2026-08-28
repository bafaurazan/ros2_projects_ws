#!/usr/bin/bash

# Private helpers for build/cbuild (short names). Bound to build::_* via helpers_list.bash.

_require_ros_toolchain() {
    local mode="${1:-cbuild}"
    local -a missing=()

    command -v ros2 >/dev/null 2>&1 || missing+=(ros2)
    command -v colcon >/dev/null 2>&1 || missing+=(colcon)
    if [[ "$mode" == build ]]; then
        command -v rosdep >/dev/null 2>&1 || missing+=(rosdep)
    fi

    ((${#missing[@]} == 0)) && return 0

    echo "Error: ROS 2 build toolchain not available (missing: ${missing[*]})." >&2
    echo "Run build/cbuild inside Distrobox: ./scripts/setup.bash jazzy|humble (native Linux only)." >&2
    echo "On Windows/Git Bash use ./scripts/setup.bash macros for host helpers (e.g. notaura_ws_import_repos)." >&2
    return 1
}

_has_src_dir() {
    [[ -d "./src" ]]
}

_get_ros_distro() {
    printf '%s\n' "${ROS_DISTRO:-humble}"
}

_get_artifacts_dir() {
    printf '%s\n' "build_ws"
}

_get_pip_python() {
    if [[ -n "${VIRTUAL_ENV:-}" && -x "${VIRTUAL_ENV}/bin/python" ]]; then
        printf '%s\n' "${VIRTUAL_ENV}/bin/python"
        return 0
    fi
    if [[ -x "./.venv/bin/python" ]]; then
        printf '%s\n' "$(pwd)/.venv/bin/python"
        return 0
    fi
    if [[ -x "./venv/bin/python" ]]; then
        printf '%s\n' "$(pwd)/venv/bin/python"
        return 0
    fi
    command -v python3
}

_is_venv_python() {
    local pip_python="$1"
    [[ -n "${VIRTUAL_ENV:-}" && "$pip_python" == "${VIRTUAL_ENV}/bin/python" ]] \
        || [[ "$pip_python" == "$(pwd)/.venv/bin/python" ]] \
        || [[ "$pip_python" == "$(pwd)/venv/bin/python" ]]
}

_has_externally_managed_python() {
    local pip_python="$1"
    local py_stdlib
    py_stdlib="$("$pip_python" -c 'import sysconfig; print(sysconfig.get_path("stdlib"))' 2>/dev/null || true)"
    [[ -n "$py_stdlib" && -f "${py_stdlib}/EXTERNALLY-MANAGED" ]]
}

_collect_rosdep_paths() {
    local -a rosdep_paths=(./src)
    declare -A seen=()
    seen["./src"]=1
    local d
    while IFS= read -r -d '' d; do
        shopt -s nullglob
        local -a nested_pkgs=( "$d"/*/package.xml )
        shopt -u nullglob
        ((${#nested_pkgs[@]} >= 2)) || continue
        [[ -n ${seen[$d]:-} ]] && continue
        seen[$d]=1
        rosdep_paths+=("$d")
    done < <(find ./src -type d -print0)
    printf '%s\n' "${rosdep_paths[@]}"
}

_install_apt_packages() {
    local apt_file apt_pkg
    while IFS= read -r apt_file; do
        [[ -n "$apt_file" ]] || continue
        while IFS= read -r apt_pkg; do
            apt_pkg="$(echo "$apt_pkg" | sed 's/\s*#.*$//g' | xargs)"
            [[ -n "$apt_pkg" ]] || continue
            sudo apt-get install -y "$apt_pkg" || return 1
        done < "$apt_file"
    done < <(find ./src -type f -name apt_packages.txt)
}

_install_pip_requirements() {
    local pip_python pip_args req_file
    pip_python="$(_get_pip_python)"
    pip_args=(-r)

    if _is_venv_python "$pip_python"; then
        echo "PIP target: venv ($pip_python)"
    else
        if _has_externally_managed_python "$pip_python"; then
            pip_args=(--break-system-packages -r)
        fi
        echo "PIP target: system Python ($pip_python)"
    fi

    while IFS= read -r req_file; do
        [[ -n "$req_file" ]] || continue
        "$pip_python" -m pip install "${pip_args[@]}" "$req_file" || return 1
    done < <(find ./src -type f -name requirements.txt)
}

_source_install_overlay() {
    local install_base="$1"
    [[ -f "./${install_base}/local_setup.bash" ]] || return 0

    # Overlay this workspace only (ROS already sourced). Drop set -u for source — ament reads unset variables.
    local had_nounset=0
    if [[ $- == *u* ]]; then
        had_nounset=1
        set +u
    fi
    # shellcheck disable=SC1090
    source "./${install_base}/local_setup.bash"
    if [[ "$had_nounset" -eq 1 ]]; then
        set -u
    fi
}
