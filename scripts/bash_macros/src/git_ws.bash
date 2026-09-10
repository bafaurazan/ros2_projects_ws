#!/usr/bin/bash

# Usage: git_ws <path> [path ...]

git_ws() {
    if [[ "$#" -lt 1 ]]; then
        git_ws::_usage
        return 1
    fi

    git_ws::_require_paths "$@" || return 1

    local -a repos=()
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        repos+=("$line")
    done < <(git_ws::_find_repos "$@")

    if [[ "${#repos[@]}" -eq 0 ]]; then
        echo "git_ws: no git repositories found under: $*" >&2
        return 1
    fi

    echo "Found ${#repos[@]} repo(s). Fetching..."
    echo

    local -a apply_dirs=()
    local -a apply_actions=()
    local dir display safe_count=0
    local status=0

    for dir in "${repos[@]}"; do
        git_ws::_classify "$dir"
        display="$(git_ws::_get_display_path "$dir")"
        git_ws::_print_repo_line \
            "$display" "$_gw_branch" "$_gw_upstream" \
            "$_gw_ahead" "$_gw_behind" "$_gw_action" "$_gw_reason"
        git_ws::_print_fetch_out "$_gw_fetch_out"

        if [[ "$_gw_action" == "pull" || "$_gw_action" == "push" ]]; then
            apply_dirs+=("$dir")
            apply_actions+=("$_gw_action")
            safe_count=$((safe_count + 1))
        fi
    done

    echo
    if [[ "$safe_count" -eq 0 ]]; then
        echo "Nothing safe to pull/push."
        return 0
    fi

    if ! git_ws::_confirm_apply "$safe_count"; then
        echo "Skipped."
        return 0
    fi

    echo
    local i
    for i in "${!apply_dirs[@]}"; do
        git_ws::_apply_safe "${apply_dirs[$i]}" "${apply_actions[$i]}" || status=1
    done
    return "$status"
}
