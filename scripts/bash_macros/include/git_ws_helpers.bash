#!/usr/bin/bash

# Private helpers for git_ws. Bodies are git_ws::_*.

git_ws::_usage() {
    echo "Usage: git_ws <path> [path ...]" >&2
    echo "  Discover git repos under the given paths, fetch, report status," >&2
    echo "  and optionally apply safe pull/push/switch." >&2
    echo "  Always also checks the ros2_projects_ws repo (ROS2_PROJECTS_WS_ROOT)." >&2
    echo "  Example: git_ws .   # all nested repos under workspace root" >&2
    echo "           git_ws src/notaura_ws/docs src/notaura_ws/src" >&2
}

# Print canonical toplevel of the meta-workspace git repo, or fail.
git_ws::_get_workspace_repo() {
    local root="${ROS2_PROJECTS_WS_ROOT:-}"
    if [[ -z "$root" ]]; then
        echo "git_ws: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi
    if [[ ! -e "$root" ]]; then
        echo "git_ws: workspace root not found: ${root}" >&2
        return 1
    fi

    local abs toplevel top_norm
    abs="$(git_ws::_get_absolute_path "$root")" || {
        echo "git_ws: cannot resolve workspace root: ${root}" >&2
        return 1
    }
    if ! git_ws::_is_git_dir "$abs"; then
        echo "git_ws: workspace root is not a git repo: ${abs}" >&2
        return 1
    fi
    toplevel="$(git -C "$abs" rev-parse --show-toplevel 2>/dev/null)" || {
        echo "git_ws: not a usable git repo: ${abs}" >&2
        return 1
    }
    top_norm="$(git_ws::_get_absolute_path "$toplevel" || printf '%s\n' "$toplevel")"
    printf '%s\n' "$top_norm"
}

git_ws::_get_absolute_path() {
    local path="$1"
    (cd "$path" && pwd) 2>/dev/null
}

git_ws::_get_display_path() {
    local toplevel="$1"
    local root="${ROS2_PROJECTS_WS_ROOT:-}"
    local top_norm root_norm
    top_norm="$(git_ws::_get_absolute_path "$toplevel" || printf '%s\n' "$toplevel")"
    if [[ -n "$root" ]]; then
        root_norm="$(git_ws::_get_absolute_path "$root" || printf '%s\n' "$root")"
        if [[ "$top_norm" == "$root_norm" ]]; then
            printf '%s\n' "."
            return 0
        fi
        if [[ "$top_norm" == "$root_norm"/* ]]; then
            printf '%s\n' "${top_norm#"${root_norm}/"}"
            return 0
        fi
    fi
    printf '%s\n' "$top_norm"
}

git_ws::_is_git_dir() {
    local path="$1"
    [[ -e "${path}/.git" ]]
}

git_ws::_require_paths() {
    local path
    for path in "$@"; do
        if [[ ! -e "$path" ]]; then
            echo "git_ws: path not found: ${path}" >&2
            return 1
        fi
    done
}

# Print unique repo toplevels under the given paths (one per line).
# Always includes a path that is itself a git root, then recursively finds
# nested .git entries under the path (pruning build/build_ws/install/log/trash).
# Paths must already exist (see git_ws::_require_paths).
git_ws::_find_repos() {
    local -A seen=()
    local path abs git_entry repo_dir toplevel top_norm

    for path in "$@"; do
        abs="$(git_ws::_get_absolute_path "$path")" || return 1

        if git_ws::_is_git_dir "$abs"; then
            toplevel="$(git -C "$abs" rev-parse --show-toplevel 2>/dev/null)" || {
                echo "git_ws: not a usable git repo: ${abs}" >&2
                return 1
            }
            top_norm="$(git_ws::_get_absolute_path "$toplevel" || printf '%s\n' "$toplevel")"
            if [[ -z ${seen[$top_norm]+x} ]]; then
                seen[$top_norm]=1
                printf '%s\n' "$top_norm"
            fi
        fi

        while IFS= read -r -d '' git_entry; do
            repo_dir="$(dirname "$git_entry")"
            toplevel="$(git -C "$repo_dir" rev-parse --show-toplevel 2>/dev/null)" || continue
            top_norm="$(git_ws::_get_absolute_path "$toplevel" || printf '%s\n' "$toplevel")"
            if [[ -z ${seen[$top_norm]+x} ]]; then
                seen[$top_norm]=1
                printf '%s\n' "$top_norm"
            fi
        done < <(
            find "$abs" -maxdepth 12 \
                \( -name build -o -name build_ws -o -name install -o -name log -o -name trash \) -prune -o \
                \( -name .git -print0 -prune \) 2>/dev/null
        )
    done
}

git_ws::_is_dirty() {
    local dir="$1"
    [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]]
}

# True if ref exists in the repo (e.g. refs/remotes/origin/develop).
git_ws::_has_ref() {
    local dir="$1"
    local ref="$2"
    git -C "$dir" show-ref --verify --quiet "$ref"
}

# Print short integration branch name if HEAD is an ancestor of that remote
# tip. Prefer origin/develop, then origin/main.
git_ws::_find_merge_target() {
    local dir="$1"
    local name remote_ref
    for name in develop main; do
        remote_ref="refs/remotes/origin/${name}"
        if ! git_ws::_has_ref "$dir" "$remote_ref"; then
            continue
        fi
        if git -C "$dir" merge-base --is-ancestor HEAD "$remote_ref" 2>/dev/null; then
            printf '%s\n' "$name"
            return 0
        fi
    done
    return 1
}

# Prefer origin/develop, else origin/main (existence only).
git_ws::_get_integration_branch() {
    local dir="$1"
    local name
    for name in develop main; do
        if git_ws::_has_ref "$dir" "refs/remotes/origin/${name}"; then
            printf '%s\n' "$name"
            return 0
        fi
    done
    return 1
}

# True when branch.<name>.remote/.merge are set but the remote-tracking ref is gone
# (typical after PR merge + remote branch delete + fetch --prune, incl. squash).
git_ws::_has_gone_upstream() {
    local dir="$1"
    local branch="$2"
    local remote merge_ref short remote_ref
    remote="$(git -C "$dir" config --get "branch.${branch}.remote" 2>/dev/null)" || return 1
    merge_ref="$(git -C "$dir" config --get "branch.${branch}.merge" 2>/dev/null)" || return 1
    [[ -n "$remote" && -n "$merge_ref" ]] || return 1
    short="${merge_ref#refs/heads/}"
    [[ "$short" != "$merge_ref" ]] || return 1
    remote_ref="refs/remotes/${remote}/${short}"
    ! git_ws::_has_ref "$dir" "$remote_ref"
}

# Fetch --prune, then set sync globals for one repo:
#   _gw_branch _gw_upstream _gw_ahead _gw_behind _gw_action _gw_reason
#   _gw_fetch_ok _gw_fetch_out _gw_switch_target
git_ws::_fetch_and_assess_repo() {
    local dir="$1"
    local fetch_status=0
    local merge_target=""
    _gw_branch=""
    _gw_upstream=""
    _gw_ahead=0
    _gw_behind=0
    _gw_action="manual"
    _gw_reason=""
    _gw_fetch_ok=0
    _gw_fetch_out=""
    _gw_switch_target=""

    _gw_fetch_out="$(git -C "$dir" fetch --prune --no-progress 2>&1)"
    fetch_status=$?
    if [[ "$fetch_status" -ne 0 ]]; then
        _gw_reason="fetch failed"
        _gw_branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")"
        return 0
    fi
    _gw_fetch_ok=1

    _gw_branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")"
    if [[ "$_gw_branch" == "HEAD" ]]; then
        _gw_reason="detached HEAD"
        return 0
    fi

    if ! _gw_upstream="$(git -C "$dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)"; then
        _gw_upstream=""
        if git_ws::_is_dirty "$dir"; then
            _gw_action="no upstream"
            _gw_reason="uncommitted changes"
            return 0
        fi
        if merge_target="$(git_ws::_find_merge_target "$dir")"; then
            if [[ "$_gw_branch" != "$merge_target" ]]; then
                _gw_action="merged"
                _gw_reason="into ${merge_target}"
                _gw_switch_target="$merge_target"
                return 0
            fi
            _gw_action="no upstream"
            _gw_reason="set upstream: git branch -u origin/${merge_target}"
            return 0
        fi
        if git_ws::_has_gone_upstream "$dir" "$_gw_branch"; then
            if merge_target="$(git_ws::_get_integration_branch "$dir")"; then
                if [[ "$_gw_branch" != "$merge_target" ]]; then
                    _gw_action="merged"
                    _gw_reason="upstream gone; into ${merge_target}"
                    _gw_switch_target="$merge_target"
                    return 0
                fi
                _gw_action="no upstream"
                _gw_reason="set upstream: git branch -u origin/${merge_target}"
                return 0
            fi
        fi
        if [[ "$_gw_branch" == "develop" || "$_gw_branch" == "main" ]] \
            && git_ws::_has_ref "$dir" "refs/remotes/origin/${_gw_branch}"; then
            _gw_action="no upstream"
            _gw_reason="set upstream: git branch -u origin/${_gw_branch}"
            return 0
        fi
        _gw_action="no upstream"
        _gw_reason="no upstream"
        return 0
    fi

    if git_ws::_is_dirty "$dir"; then
        _gw_reason="uncommitted changes"
        _gw_ahead="$(git -C "$dir" rev-list --count "${_gw_upstream}..HEAD" 2>/dev/null || echo 0)"
        _gw_behind="$(git -C "$dir" rev-list --count "HEAD..${_gw_upstream}" 2>/dev/null || echo 0)"
        return 0
    fi

    _gw_ahead="$(git -C "$dir" rev-list --count "${_gw_upstream}..HEAD" 2>/dev/null || echo 0)"
    _gw_behind="$(git -C "$dir" rev-list --count "HEAD..${_gw_upstream}" 2>/dev/null || echo 0)"

    if [[ "$_gw_ahead" -gt 0 && "$_gw_behind" -gt 0 ]]; then
        _gw_reason="diverged (ahead ${_gw_ahead}, behind ${_gw_behind})"
        return 0
    fi
    if [[ "$_gw_behind" -gt 0 ]]; then
        _gw_action="pull"
        _gw_reason=""
        return 0
    fi
    if [[ "$_gw_ahead" -gt 0 ]]; then
        _gw_action="push"
        _gw_reason=""
        return 0
    fi

    if [[ -n "$_gw_fetch_out" ]]; then
        _gw_action="info"
    else
        _gw_action="ok"
    fi
    _gw_reason=""
}

git_ws::_print_fetch_out() {
    local fetch_out="$1"
    local line
    [[ -n "$fetch_out" ]] || return 0
    while IFS= read -r line || [[ -n "$line" ]]; do
        printf '  %s\n' "$line"
    done <<< "$fetch_out"
}

git_ws::_print_repo_line() {
    local display="$1"
    local branch="$2"
    local upstream="$3"
    local ahead="$4"
    local behind="$5"
    local action="$6"
    local reason="$7"

    local sync="ahead ${ahead}, behind ${behind}"
    local up_txt="${upstream:-none}"
    local line="[${action}] ${display}  branch=${branch}  upstream=${up_txt}  ${sync}"
    if [[ -n "$reason" ]]; then
        line+="  (${reason})"
    fi
    printf '%s\n' "$line"
}

git_ws::_confirm_apply() {
    local count="$1"
    local reply=""
    printf 'Apply safe pull/push/switch on %s repo(s)? [y/N] ' "$count"
    read -r reply || true
    [[ "$reply" == "y" || "$reply" == "Y" ]]
}

# action: pull | push | switch. For switch, pass target as $3.
git_ws::_apply_safe() {
    local dir="$1"
    local action="$2"
    local target="${3:-}"
    local display
    display="$(git_ws::_get_display_path "$dir")"

    case "$action" in
        pull)
            echo "→ pull --ff-only: ${display}"
            if git -C "$dir" pull --ff-only; then
                echo "  ok"
            else
                echo "  FAILED" >&2
                return 1
            fi
            ;;
        push)
            echo "→ push: ${display}"
            if git -C "$dir" push; then
                echo "  ok"
            else
                echo "  FAILED" >&2
                return 1
            fi
            ;;
        switch)
            echo "→ switch ${target} + pull --ff-only: ${display}"
            if ! git -C "$dir" switch "$target"; then
                echo "  FAILED" >&2
                return 1
            fi
            if git -C "$dir" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
                if ! git -C "$dir" pull --ff-only; then
                    echo "  FAILED" >&2
                    return 1
                fi
            fi
            echo "  ok"
            ;;
        *)
            return 0
            ;;
    esac
}
