#!/usr/bin/bash

# Private helpers for load_macros (short names). Bound to load::_* via helpers_list.bash.

_get_repo_from_path() {
    # …/<repo>/scripts/bash_macros → <repo>
    local macros_dir="$1"
    local scripts_dir
    scripts_dir="$(dirname "$macros_dir")"
    basename "$(dirname "$scripts_dir")"
}

_has_workspace_root() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]]
}

_find_sources() {
    local root="$1"
    local src_root="${root}/src"
    local macros_dir

    if [[ -d "${root}/scripts/bash_macros" ]]; then
        printf '%s\n' "${root}/scripts/bash_macros"
    fi

    [[ -d "$src_root" ]] || return 0

    while IFS= read -r -d '' macros_dir; do
        printf '%s\n' "$macros_dir"
    done < <(
        find "$src_root" -maxdepth 12 -type d -path '*/scripts/bash_macros' \
            -not -path '*/build/*' \
            -not -path '*/build_ws/*' \
            -not -path '*/install/*' \
            -not -path '*/log/*' \
            -not -path '*/.git/*' \
            -print0 2>/dev/null
    )
}

_list_api_files() {
    local src="$1"
    local file
    shopt -s nullglob
    if [[ -d "${src}/src" ]]; then
        for file in "$src"/src/*.bash; do
            printf '%s\n' "$file"
        done
    fi
    shopt -u nullglob
}

_extract_functions() {
    local file="$1"
    local line name
    while IFS= read -r line; do
        name="$(sed -E 's/^[[:space:]]*(function[[:space:]]+)?(([a-zA-Z_][a-zA-Z0-9_]*::)*)([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\).*/\4/' <<<"$line")"
        [[ "$name" == _* ]] && continue
        [[ "$line" == *::* ]] && continue
        printf '%s\n' "$name"
    done < <(grep -E '^[[:space:]]*(function[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_]*::)*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)' "$file" 2>/dev/null || true)
}

_has_nounset() {
    [[ $- == *u* ]]
}

_source_bundle_macros() {
    local bundle="$1"
    [[ -f "${bundle}/launch/macros.bash" ]] || return 0
    # shellcheck disable=SC1091
    source "${bundle}/launch/macros.bash"
}

_source_direct_files() {
    local had_nounset=0
    local src

    if _has_nounset; then
        had_nounset=1
        set +u
    fi

    for src in "$@"; do
        _source_bundle_macros "$src"
    done

    if [[ "$had_nounset" -eq 1 ]]; then
        set -u
    fi
}
