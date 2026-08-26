#!/usr/bin/bash

# Private helpers for sync_macros (short names). Bound to sync::_* via helpers_list.bash.

_get_repo_from_path() {
    # …/<repo>/scripts/macros → <repo>
    local macros_dir="$1"
    local scripts_dir
    scripts_dir="$(dirname "$macros_dir")"
    basename "$(dirname "$scripts_dir")"
}

_has_workspace_root() {
    [[ -n "${ROS2_PROJECTS_WS_ROOT:-}" ]]
}

_get_dest_root() {
    printf '%s\n' "${ROS2_PROJECTS_WS_ROOT}/build_ws/macros"
}

_find_sources() {
    local root="$1"
    local src_root="${root}/src"
    local macros_dir

    if [[ -d "${root}/scripts/macros" ]]; then
        printf '%s\n' "${root}/scripts/macros"
    fi

    [[ -d "$src_root" ]] || return 0

    while IFS= read -r -d '' macros_dir; do
        printf '%s\n' "$macros_dir"
    done < <(
        find "$src_root" -maxdepth 12 -type d -path '*/scripts/macros' \
            -not -path '*/build/*' \
            -not -path '*/build_ws/*' \
            -not -path '*/install/*' \
            -not -path '*/log/*' \
            -not -path '*/.git/*' \
            -print0 2>/dev/null
    )
}

_extract_functions() {
    local file="$1"
    local line name
    while IFS= read -r line; do
        # Allow optional namespace:: before the function name (ignored for public API).
        name="$(sed -E 's/^[[:space:]]*(function[[:space:]]+)?(([a-zA-Z_][a-zA-Z0-9_]*::)*)([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\).*/\4/' <<<"$line")"
        [[ "$name" == _* ]] && continue
        [[ "$line" == *::* ]] && continue
        printf '%s\n' "$name"
    done < <(grep -E '^[[:space:]]*(function[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_]*::)*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)' "$file" 2>/dev/null || true)
}

_copy_bundle() {
    local source_dir="$1"
    local dest_dir="$2"
    rm -rf "$dest_dir"
    mkdir -p "$dest_dir"
    cp -a "${source_dir}/." "$dest_dir/"
}

_has_nounset() {
    [[ $- == *u* ]]
}

_source_cache() {
    local dest_root="$1"
    local had_nounset=0
    local file repo_dir

    if _has_nounset; then
        had_nounset=1
        set +u
    fi

    shopt -s nullglob
    for repo_dir in "${dest_root}"/*/; do
        if [[ -d "${repo_dir}api" ]]; then
            for file in "${repo_dir}api"/*.bash; do
                # shellcheck disable=SC1090
                source "$file"
            done
        else
            for file in "${repo_dir}"*.bash; do
                # shellcheck disable=SC1090
                source "$file"
            done
        fi
    done
    shopt -u nullglob

    if [[ "$had_nounset" -eq 1 ]]; then
        set -u
    fi
}
