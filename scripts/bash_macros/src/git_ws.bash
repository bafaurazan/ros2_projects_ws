#!/usr/bin/bash

# Usage: git_ws <path> [path ...]

git_ws() {
    if [[ "$#" -lt 1 ]]; then
        git_ws::_usage
        return 1
    fi

    git_ws::_require_paths "$@" || return 1

    local ws_repo
    ws_repo="$(git_ws::_get_workspace_repo)" || return 1

    # Meta-workspace first; user paths next (dedupe if root already listed).
    local -a repos=("$ws_repo")
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        if [[ "$line" != "$ws_repo" ]]; then
            repos+=("$line")
        fi
    done < <(git_ws::_find_repos "$@")

    echo "Found ${#repos[@]} repo(s). Fetching..."
    echo

    _gw_summary_paths=()
    _gw_summary_actions=()

    local dir status=0
    for dir in "${repos[@]}"; do
        git_ws::_process_repo "$dir" || status=1
    done
    git_ws::_print_summary
    return "$status"
}
