#!/usr/bin/bash

# Usage: load_macros

_macros_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${_macros_dir}/include/helpers_list.bash"
unset _macros_dir

load_macros() {
    if ! load::_has_workspace_root; then
        echo "load_macros: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi

    local root="${ROS2_PROJECTS_WS_ROOT}"

    local -a sources=()
    local src
    while IFS= read -r src; do
        [[ -n "$src" ]] || continue
        sources+=("$src")
    done < <(load::_find_sources "$root")

    declare -A repo_from=()
    local -a ordered_repos=()
    local repo file fn
    local collision=0

    for src in "${sources[@]}"; do
        repo="$(load::_get_repo_from_path "$src")"
        if [[ -n ${repo_from[$repo]:-} && ${repo_from[$repo]} != "$src" ]]; then
            echo "load_macros: duplicate repo name '$repo':" >&2
            echo "  ${repo_from[$repo]}" >&2
            echo "  $src" >&2
            collision=1
            continue
        fi
        if [[ -z ${repo_from[$repo]:-} ]]; then
            ordered_repos+=("$repo")
        fi
        repo_from[$repo]="$src"
    done

    declare -A fn_from=()
    local -a source_dirs=()

    for repo in "${ordered_repos[@]}"; do
        src="${repo_from[$repo]}"
        source_dirs+=("$src")
        while IFS= read -r file; do
            [[ -n "$file" ]] || continue
            while IFS= read -r fn; do
                [[ -n "$fn" ]] || continue
                if [[ -n ${fn_from[$fn]:-} ]]; then
                    echo "load_macros: duplicate function '$fn':" >&2
                    echo "  ${fn_from[$fn]}" >&2
                    echo "  $file" >&2
                    collision=1
                    continue
                fi
                fn_from[$fn]="$file"
            done < <(load::_extract_functions "$file")
        done < <(load::_list_api_files "$src")
    done

    if [[ "$collision" -eq 1 ]]; then
        echo "load_macros: aborted (fix name collisions, then run load_macros again)" >&2
        return 1
    fi

    if [[ ${#source_dirs[@]} -gt 0 ]]; then
        load::_source_direct_files "${source_dirs[@]}"
    fi
}
