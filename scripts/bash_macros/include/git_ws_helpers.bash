#!/usr/bin/bash

# Private helpers for git_ws. Bodies are git_ws::_*.

git_ws::_usage() {
    echo "Usage: git_ws <path> [path ...]" >&2
    echo "  Discover git repos under the given paths, fetch --prune, print a" >&2
    echo "  diag-style report per repo (vs origin/develop), then ask y/N" >&2
    echo "  (pull: y/i/N; orphan locals: p/d/N with delete confirm) separately." >&2
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
            printf '%s\n' "$top_norm"
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

git_ws::_has_develop() {
    local dir="$1"
    git_ws::_has_ref "$dir" "refs/remotes/origin/develop"
}

# Classify tip vs origin/develop. Sets _gw_merge_kind to:
#   ancestor   — tip is a literal ancestor of origin/develop
#   equivalent — merge-tree into develop yields develop's tree
#   squash     — squash/PR evidence on develop (GitHub-style leftover branch)
#   ""         — not fully in develop
# Also sets _gw_merge_detail (optional, e.g. "#8" or short sha).
# Returns 0 when merged (ancestor | equivalent | squash), 1 otherwise.
git_ws::_classify_develop_merge() {
    local dir="$1"
    local tip="$2"
    local merged_tree dev_tree branch_for_search
    _gw_merge_kind=""
    _gw_merge_detail=""

    git_ws::_has_develop "$dir" || return 1

    if git -C "$dir" merge-base --is-ancestor "$tip" "refs/remotes/origin/develop" 2>/dev/null; then
        _gw_merge_kind="ancestor"
        return 0
    fi

    # Content already in develop (clean merge-tree result == develop tree).
    if merged_tree="$(git -C "$dir" merge-tree --write-tree --no-messages \
        "refs/remotes/origin/develop" "$tip" 2>/dev/null)"; then
        if [[ "$merged_tree" =~ ^[0-9a-f]{40,64}$ ]]; then
            dev_tree="$(git -C "$dir" rev-parse "refs/remotes/origin/develop^{tree}" 2>/dev/null)" || true
            if [[ -n "$dev_tree" && "$merged_tree" == "$dev_tree" ]]; then
                _gw_merge_kind="equivalent"
                return 0
            fi
        fi
    fi

    # Squash / GitHub PR: tip SHAs are not ancestors; merge-tree may conflict
    # after develop moved. Look for squash/PR evidence on develop.
    branch_for_search="$tip"
    if [[ "$tip" == "HEAD" ]]; then
        branch_for_search="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    fi
    if [[ -n "$branch_for_search" && "$branch_for_search" != "HEAD" ]]; then
        if git_ws::_find_squash_pr_on_develop "$dir" "$branch_for_search"; then
            _gw_merge_kind="squash"
            return 0
        fi
    fi
    return 1
}

# True if tip is in origin/develop (true merge, content-equivalent, or squash/PR).
git_ws::_is_merged_into_develop() {
    local dir="$1"
    local tip="$2"
    git_ws::_classify_develop_merge "$dir" "$tip"
}

# Look for squash/PR evidence on origin/develop for a local branch name.
# Sets _gw_merge_detail on success. Prefers gh pr list, else git log --grep.
git_ws::_find_squash_pr_on_develop() {
    local dir="$1"
    local branch="$2"
    local short soft hit subject pr_num remote_url repo pat line sha
    local -a patterns=()
    _gw_merge_detail=""

    [[ -n "$branch" ]] || return 1

    if command -v gh >/dev/null 2>&1; then
        remote_url="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
        if [[ -n "$remote_url" ]]; then
            repo="$(printf '%s\n' "$remote_url" \
                | sed -E 's#^git@[^:]+:##; s#^https?://[^/]+/##; s#\.git$##')"
            if [[ -n "$repo" ]]; then
                hit="$(gh pr list -R "$repo" --state merged --base develop \
                    --head "$branch" --limit 1 \
                    --json number,mergeCommit \
                    --jq '.[0] | select(. != null) | "\(.number)"' \
                    2>/dev/null || true)"
                if [[ -n "$hit" ]]; then
                    _gw_merge_detail="#${hit}"
                    return 0
                fi
            fi
        fi
    fi

    short="${branch##*/}"
    soft="${short//_/ }"
    soft="${soft//-/ }"
    patterns+=("$branch")
    [[ "$short" != "$branch" ]] && patterns+=("$short")
    [[ "$soft" != "$short" ]] && patterns+=("$soft")

    for pat in "${patterns[@]}"; do
        [[ ${#pat} -ge 6 ]] || continue
        while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            sha="${line%% *}"
            subject="${line#* }"
            # Prefer GitHub-style subjects with (#N).
            if [[ "$subject" =~ \(\#[0-9]+\) ]]; then
                pr_num="$(printf '%s\n' "$subject" | sed -nE 's/.*\(#([0-9]+)\).*/\1/p')"
                _gw_merge_detail="#${pr_num}"
                return 0
            fi
            # Single-parent commit mentioning the branch (squash-like).
            if [[ "$(git -C "$dir" rev-list --parents -n 1 "$sha" | awk '{print NF-1}')" -eq 1 ]]; then
                _gw_merge_detail="$(git -C "$dir" rev-parse --short "$sha")"
                return 0
            fi
        done < <(git -C "$dir" log "refs/remotes/origin/develop" \
            --format='%H %s' -i --fixed-strings --grep="$pat" -n 20 2>/dev/null)
    done
    return 1
}

git_ws::_get_develop_merge_note() {
    case "${_gw_merge_kind}" in
        ancestor)
            printf '%s\n' "merged into develop (safe to delete)"
            ;;
        equivalent)
            printf '%s\n' "merged into develop via equivalent commits (safe to delete)"
            ;;
        squash)
            if [[ -n "$_gw_merge_detail" ]]; then
                printf '%s\n' "merged into develop via squash/PR ${_gw_merge_detail} (safe to delete)"
            else
                printf '%s\n' "merged into develop via squash/PR (safe to delete)"
            fi
            ;;
        *)
            printf '%s\n' "not in develop (has unique commits)"
            ;;
    esac
}

# Print "ahead N, behind M" of tip vs origin/develop; or "n/a" if no develop.
git_ws::_get_vs_develop_text() {
    local dir="$1"
    local tip="$2"
    local ahead behind
    if ! git_ws::_has_develop "$dir"; then
        printf '%s\n' "n/a (no origin/develop)"
        return 0
    fi
    ahead="$(git -C "$dir" rev-list --count "refs/remotes/origin/develop..${tip}" 2>/dev/null || echo "?")"
    behind="$(git -C "$dir" rev-list --count "${tip}..refs/remotes/origin/develop" 2>/dev/null || echo "?")"
    printf 'ahead %s, behind %s\n' "$ahead" "$behind"
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

# Fetch --prune, then set globals for one repo via _assess_repo.
#   _gw_branch _gw_upstream _gw_ahead _gw_behind
#   _gw_dev_ahead _gw_dev_behind _gw_has_develop
#   _gw_action _gw_reason _gw_fetch_ok _gw_fetch_out _gw_switch_target
# Actions: ok|develop|behind-develop|pull|push|push-upstream|switch|manual
# Display may append " - info" when fetch printed news (see _get_action_label).
git_ws::_fetch_and_assess_repo() {
    local dir="$1"
    local fetch_status=0
    _gw_branch=""
    _gw_upstream=""
    _gw_ahead=0
    _gw_behind=0
    _gw_dev_ahead=0
    _gw_dev_behind=0
    _gw_has_develop=0
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
    git_ws::_assess_repo "$dir"
}

# Assess repo state into globals (no fetch). Uses existing _gw_fetch_out for info suffix.
git_ws::_assess_repo() {
    local dir="$1"

    _gw_branch=""
    _gw_upstream=""
    _gw_ahead=0
    _gw_behind=0
    _gw_dev_ahead=0
    _gw_dev_behind=0
    _gw_has_develop=0
    _gw_action="manual"
    _gw_reason=""
    _gw_switch_target=""

    if git_ws::_has_develop "$dir"; then
        _gw_has_develop=1
    fi

    _gw_branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")"
    if [[ "$_gw_branch" == "HEAD" ]]; then
        _gw_reason="detached HEAD"
        return 0
    fi

    if [[ "$_gw_has_develop" -eq 1 ]]; then
        _gw_dev_ahead="$(git -C "$dir" rev-list --count "refs/remotes/origin/develop..HEAD" 2>/dev/null || echo 0)"
        _gw_dev_behind="$(git -C "$dir" rev-list --count "HEAD..refs/remotes/origin/develop" 2>/dev/null || echo 0)"
    fi

    if [[ "$_gw_has_develop" -eq 0 ]]; then
        _gw_reason="no origin/develop"
        return 0
    fi

    if git_ws::_is_dirty "$dir"; then
        _gw_reason="uncommitted changes"
        if _gw_upstream="$(git -C "$dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)"; then
            _gw_ahead="$(git -C "$dir" rev-list --count "${_gw_upstream}..HEAD" 2>/dev/null || echo 0)"
            _gw_behind="$(git -C "$dir" rev-list --count "HEAD..${_gw_upstream}" 2>/dev/null || echo 0)"
        else
            _gw_upstream=""
        fi
        return 0
    fi

    if _gw_upstream="$(git -C "$dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)"; then
        _gw_ahead="$(git -C "$dir" rev-list --count "${_gw_upstream}..HEAD" 2>/dev/null || echo 0)"
        _gw_behind="$(git -C "$dir" rev-list --count "HEAD..${_gw_upstream}" 2>/dev/null || echo 0)"

        if [[ "$_gw_ahead" -gt 0 && "$_gw_behind" -gt 0 ]]; then
            _gw_reason="diverged (ahead ${_gw_ahead}, behind ${_gw_behind})"
            return 0
        fi
        if [[ "$_gw_behind" -gt 0 ]]; then
            _gw_action="pull"
            _gw_reason="behind upstream by ${_gw_behind} — git pull --ff-only"
            return 0
        fi
        if [[ "$_gw_ahead" -gt 0 ]]; then
            _gw_action="push"
            _gw_reason="ahead of upstream by ${_gw_ahead} — git push"
            return 0
        fi
        if [[ "${_gw_dev_behind:-0}" -gt 0 ]]; then
            _gw_action="behind-develop"
        elif [[ "$_gw_branch" == "develop" ]]; then
            _gw_action="develop"
        else
            _gw_action="ok"
        fi
        _gw_reason=""
        return 0
    fi

    _gw_upstream=""

    # No @{u}. Remote branch with same name exists → missing tracking → manual.
    if git_ws::_has_ref "$dir" "refs/remotes/origin/${_gw_branch}"; then
        _gw_action="manual"
        _gw_reason="remote exists but no upstream tracking"
        return 0
    fi

    # Gone upstream config (remote deleted) or never published.
    if [[ "$_gw_branch" != "develop" ]] && git_ws::_is_merged_into_develop "$dir" "HEAD"; then
        _gw_action="switch"
        _gw_switch_target="develop"
        if git_ws::_has_gone_upstream "$dir" "$_gw_branch"; then
            _gw_reason="upstream gone; merged into develop — git switch develop"
        else
            _gw_reason="no remote; merged into develop — git switch develop"
        fi
        return 0
    fi

    if [[ "$_gw_branch" == "develop" ]]; then
        # No set-upstream; missing tracking on develop is a manual fix.
        _gw_action="manual"
        _gw_reason="on develop but no upstream tracking"
        return 0
    fi

    _gw_action="push-upstream"
    _gw_reason="no remote branch — git push --set-upstream origin ${_gw_branch}"
}

git_ws::_print_fetch_section() {
    local fetch_out="$1"
    local line
    [[ -n "$fetch_out" ]] || return 0
    echo
    echo "info:"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" ]] || continue
        printf '  %s\n' "$line"
    done <<< "$fetch_out"
}

# Print remote branches (except origin/develop and origin/HEAD) vs develop.
git_ws::_print_remote_vs_develop() {
    local dir="$1"
    local ref short vs
    local any=0

    if [[ "$_gw_has_develop" -eq 0 ]]; then
        return 0
    fi

    while IFS= read -r ref; do
        [[ -n "$ref" ]] || continue
        short="${ref#refs/remotes/}"
        [[ "$short" == "origin/develop" || "$short" == "origin/HEAD" ]] && continue
        if [[ "$any" -eq 0 ]]; then
            echo
            echo "remote branches vs develop:"
            any=1
        fi
        vs="$(git_ws::_get_vs_develop_text "$dir" "$ref")"
        printf '  %-28s %s\n' "$short" "$vs"
    done < <(git -C "$dir" for-each-ref --format='%(refname)' refs/remotes/origin/ 2>/dev/null | sort)
}

# Print locals without origin/<name>. Fills global array _gw_orphan_branches.
git_ws::_print_orphan_locals() {
    local dir="$1"
    local name vs note
    local any=0
    _gw_orphan_branches=()

    while IFS= read -r name; do
        [[ -n "$name" ]] || continue
        if git_ws::_has_ref "$dir" "refs/remotes/origin/${name}"; then
            continue
        fi
        _gw_orphan_branches+=("$name")
        if [[ "$any" -eq 0 ]]; then
            echo
            echo "local without remote:"
            any=1
        fi
        if git_ws::_classify_develop_merge "$dir" "$name"; then
            note="$(git_ws::_get_develop_merge_note)"
        else
            note="not in develop (has unique commits)"
        fi
        vs="$(git_ws::_get_vs_develop_text "$dir" "refs/heads/${name}")"
        printf '  %-28s %s  (%s)\n' "$name" "$vs" "$note"
    done < <(git -C "$dir" for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null | sort)
}

# Display label for _gw_action; appends " - info" when fetch printed news.
git_ws::_get_action_label() {
    if [[ -n "${_gw_fetch_out:-}" ]]; then
        printf '%s - info\n' "$_gw_action"
    else
        printf '%s\n' "$_gw_action"
    fi
}

git_ws::_print_repo_report() {
    local dir="$1"
    local display label
    display="$(git_ws::_get_display_path "$dir")"
    label="$(git_ws::_get_action_label)"

    echo "===="
    echo "${display}"
    echo "===="
    if [[ -n "$_gw_reason" ]]; then
        printf '[%s] %s\n' "$label" "$_gw_reason"
    else
        printf '[%s]\n' "$label"
    fi
    echo
    printf 'branch:     %s\n' "${_gw_branch}"
    if [[ "$_gw_has_develop" -eq 1 ]]; then
        printf 'vs develop: ahead %s, behind %s\n' "${_gw_dev_ahead}" "${_gw_dev_behind}"
    else
        printf 'vs develop: n/a (no origin/develop)\n'
    fi
    if [[ -n "$_gw_upstream" ]]; then
        printf 'vs upstream: %s  ahead %s, behind %s\n' \
            "$_gw_upstream" "$_gw_ahead" "$_gw_behind"
    else
        printf 'vs upstream: none\n'
    fi
    git_ws::_print_fetch_section "$_gw_fetch_out"
    git_ws::_print_remote_vs_develop "$dir"
    git_ws::_print_orphan_locals "$dir"
}

# Read interactive reply from the controlling terminal (not from a here-string/pipe).
git_ws::_read_tty() {
    local __gw_reply_var="$1"
    local __gw_reply=""
    if [[ -r /dev/tty ]]; then
        read -r __gw_reply < /dev/tty || true
    else
        read -r __gw_reply || true
    fi
    printf -v "$__gw_reply_var" '%s' "$__gw_reply"
}

git_ws::_confirm_yes() {
    local prompt="$1"
    local reply=""
    echo
    printf '%s [y/N] ' "$prompt"
    git_ws::_read_tty reply
    [[ "$reply" == "y" || "$reply" == "Y" ]]
}

# Print commits and diff that an ff-only pull would bring (HEAD..upstream).
git_ws::_print_incoming_pull_diff() {
    local dir="$1"
    local upstream="${_gw_upstream}"

    if [[ -z "$upstream" ]]; then
        echo "incoming: no upstream"
        return 0
    fi

    echo
    echo "incoming (HEAD..${upstream}):"
    git -C "$dir" log --oneline "HEAD..${upstream}" 2>/dev/null || true
    echo
    echo "incoming diff (--stat):"
    git -C "$dir" diff --stat "HEAD...${upstream}" 2>/dev/null || true
    echo
    echo "incoming diff:"
    git -C "$dir" --no-pager diff "HEAD...${upstream}" 2>/dev/null || true
    echo
}

# Prompt for pull: y=apply, i=show incoming diff, N=skip. Returns 0 to apply.
git_ws::_confirm_pull() {
    local dir="$1"
    local reply=""

    echo
    while true; do
        echo "Apply pull --ff-only?"
        echo "  y = pull --ff-only"
        echo "  i = show incoming changes (git log + git diff)"
        echo "  N = skip (default)"
        printf 'Choose [y/i/N]: '
        git_ws::_read_tty reply
        reply="${reply:-N}"
        case "$reply" in
            y|Y)
                return 0
                ;;
            i|I)
                git_ws::_print_incoming_pull_diff "$dir"
                ;;
            *)
                return 1
                ;;
        esac
    done
}

# Prompt for orphan local: p=push -u, d=delete (always; confirm y), N=skip.
# Exit 0 always unless apply fails → return 1.
git_ws::_confirm_orphan() {
    local dir="$1"
    local name="$2"
    local display="$3"
    local merge_kind=""
    local delete_flag="-D"
    local reply=""
    local note
    local sure=""

    if git_ws::_classify_develop_merge "$dir" "$name"; then
        merge_kind="$_gw_merge_kind"
        note="$(git_ws::_get_develop_merge_note)"
        note="${note% (safe to delete)}"
        # Squash/equivalent tips are not ancestors; -d refuses — use -D
        # only after our check. Ancestor merges can use -d.
        if [[ "$merge_kind" == "equivalent" || "$merge_kind" == "squash" ]]; then
            delete_flag="-D"
        else
            delete_flag="-d"
        fi
    else
        note="not in develop — has unique commits"
        delete_flag="-D"
    fi

    echo
    echo "local without remote: ${name}  (${note})"
    echo "  p = push -u origin ${name}"
    if [[ "$delete_flag" == "-D" ]]; then
        if [[ -n "$merge_kind" ]]; then
            echo "  d = delete local branch (git branch -D; already on develop via squash/equivalent)"
        else
            echo "  d = delete local branch (git branch -D; has unique commits)"
        fi
    else
        echo "  d = delete local branch (git branch -d)"
    fi
    echo "  N = skip (default)"
    printf 'Choose [p/d/N]: '
    git_ws::_read_tty reply
    reply="${reply:-N}"

    case "$reply" in
        p|P)
            echo "→ push -u origin ${name}: ${display}"
            if git -C "$dir" push --set-upstream origin "$name"; then
                echo "  ok"
                return 0
            fi
            echo "  FAILED" >&2
            return 1
            ;;
        d|D)
            printf 'Are you sure to delete this branch? [y/N] '
            git_ws::_read_tty sure
            if [[ "$sure" != "y" && "$sure" != "Y" ]]; then
                echo "  skipped"
                return 0
            fi
            echo "→ branch ${delete_flag} ${name}: ${display}"
            if git -C "$dir" branch "$delete_flag" "$name"; then
                echo "  ok"
                return 0
            fi
            echo "  FAILED" >&2
            return 1
            ;;
        *)
            echo "  skipped"
            return 0
            ;;
    esac
}

# action: pull | push | switch | push-upstream. target used for switch / push-upstream.
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
        push-upstream)
            echo "→ push -u origin ${target}: ${display}"
            if git -C "$dir" push --set-upstream origin "$target"; then
                echo "  ok"
            else
                echo "  FAILED" >&2
                return 1
            fi
            ;;
        *)
            return 0
            ;;
    esac
}

# Fetch, report, and prompt for one repo. Returns 1 if any apply failed.
git_ws::_process_repo() {
    local dir="$1"
    local display status=0
    local name summary_label applied=0
    _gw_orphan_branches=()

    git_ws::_fetch_and_assess_repo "$dir"
    display="$(git_ws::_get_display_path "$dir")"
    git_ws::_print_repo_report "$dir"

    case "$_gw_action" in
        pull)
            if git_ws::_confirm_pull "$dir"; then
                if git_ws::_apply_safe "$dir" "pull"; then
                    applied=1
                else
                    status=1
                fi
            else
                echo "  skipped"
            fi
            ;;
        push)
            if git_ws::_confirm_yes "Apply push?"; then
                if git_ws::_apply_safe "$dir" "push"; then
                    applied=1
                else
                    status=1
                fi
            else
                echo "  skipped"
            fi
            ;;
        push-upstream)
            if git_ws::_confirm_yes "Apply push --set-upstream origin ${_gw_branch}?"; then
                if git_ws::_apply_safe "$dir" "push-upstream" "$_gw_branch"; then
                    applied=1
                else
                    status=1
                fi
            else
                echo "  skipped"
            fi
            ;;
        switch)
            if git_ws::_confirm_yes "Apply switch ${_gw_switch_target} + pull --ff-only?"; then
                if git_ws::_apply_safe "$dir" "switch" "$_gw_switch_target"; then
                    applied=1
                else
                    status=1
                fi
            else
                echo "  skipped"
            fi
            ;;
    esac

    # Orphan locals (never delete/prompt for current branch — HEAD actions above).
    for name in "${_gw_orphan_branches[@]}"; do
        [[ -n "$name" ]] || continue
        if [[ "$name" == "$_gw_branch" ]]; then
            continue
        fi
        git_ws::_confirm_orphan "$dir" "$name" "$display" || status=1
    done

    if [[ "$applied" -eq 1 ]]; then
        _gw_fetch_out=""
        git_ws::_assess_repo "$dir"
    fi
    summary_label="$(git_ws::_get_absolute_path "$dir" || printf '%s\n' "$dir")"
    summary_label="${summary_label##*/}"
    [[ -n "$summary_label" ]] || summary_label="$display"
    _gw_summary_paths+=("$summary_label")
    _gw_summary_actions+=("$(git_ws::_get_action_label)")

    echo
    return "$status"
}

# Print end-of-run status list collected during _process_repo.
git_ws::_print_summary() {
    local i
    echo "===="
    echo "summary"
    echo "===="
    for i in "${!_gw_summary_paths[@]}"; do
        printf '%s - [%s]\n' "${_gw_summary_paths[$i]}" "${_gw_summary_actions[$i]}"
    done
}
