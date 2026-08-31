#!/usr/bin/bash

# Private helpers for importer (short names). Bound to importer::_* via helpers_list.bash.

_get_config_path() {
    local bundle_dir
    bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    printf '%s\n' "${bundle_dir}/config/importer.repos"
}

# Fields: 1=name 2=github_path 3=branch 4=dest (optional)
_get_target_field() {
    local target="$1"
    local field="$2"
    local file
    file="$(_get_config_path)"
    [[ -f "$file" ]] || return 1
    awk -v t="$target" -v f="$field" '
        {
            sub(/\r$/, "")
            if ($0 ~ /^[[:space:]]*#/ || NF < 3) next
            if ($1 == t) { print $f; found = 1; exit }
        }
        END { exit !found }
    ' "$file"
}

_list_config_targets() {
    local file
    file="$(_get_config_path)"
    [[ -f "$file" ]] || return 0
    awk '
        {
            sub(/\r$/, "")
            if ($0 ~ /^[[:space:]]*#/ || NF < 3) next
            print $1
        }
    ' "$file"
}

_get_repo_path() {
    _get_target_field "$1" 2
}

_get_github_hosts() {
    local -a hosts=("github.com")
    local ssh_config="${HOME}/.ssh/config"

    if [[ -f "$ssh_config" ]]; then
        local host_alias
        while IFS= read -r host_alias; do
            [[ -n "$host_alias" ]] && hosts+=("$host_alias")
        done < <(awk '
            tolower($1) == "host" {
                if (h && (hn == "github.com" || h == "github.com") && h !~ /[*?]/) print h;
                h = $2; hn = ""; next
            }
            tolower($1) == "hostname" { hn = $2 }
            END {
                if (h && (hn == "github.com" || h == "github.com") && h !~ /[*?]/) print h;
            }
        ' "$ssh_config")
    fi

    printf '%s\n' "${hosts[@]}" | awk '!seen[$0]++'
}

_get_branch() {
    _get_target_field "$1" 3
}

_get_clone_dir() {
    local target="$1"
    local dest
    dest="$(_get_target_field "$target" 4)"
    if [[ -z "$dest" ]]; then
        dest="src/${target}"
    fi
    printf '%s\n' "${ROS2_PROJECTS_WS_ROOT:?ROS2_PROJECTS_WS_ROOT is not set}/${dest}"
}

_list_targets() {
    local file target dest
    file="$(_get_config_path)"
    echo "Usage: importer <target>"
    echo "Targets (from ${file}):"
    if [[ ! -f "$file" ]]; then
        echo "  (config file missing)"
        return 0
    fi
    while IFS= read -r target; do
        [[ -n "$target" ]] || continue
        dest="$(_get_target_field "$target" 4)"
        [[ -n "$dest" ]] || dest="src/${target}"
        echo "  ${target}    ${ROS2_PROJECTS_WS_ROOT:-<workspace>}/${dest}"
    done < <(_list_config_targets)
}

_ensure_repo() {
    local target="$1"
    local repo_path branch dest host url tried=""

    if ! load::_has_workspace_root; then
        echo "importer: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi

    repo_path="$(_get_repo_path "$target")" || {
        echo "importer: unknown target '$target'" >&2
        _list_targets >&2
        return 1
    }
    branch="$(_get_branch "$target")" || return 1
    dest="$(_get_clone_dir "$target")"

    mkdir -p "$(dirname "$dest")" || return 1

    if [[ -d "${dest}/.git" ]]; then
        echo "${target} already present at ${dest} (no-op)"
        return 2
    fi

    if [[ -e "$dest" ]]; then
        echo "importer: ${dest} exists but is not a git repository" >&2
        return 1
    fi

    echo "Cloning ${target} (${branch})..."
    while IFS= read -r host; do
        [[ -n "$host" ]] || continue
        url="git@${host}:${repo_path}.git"
        if [[ -n "$tried" ]]; then
            tried+=", ${host}"
        else
            tried="$host"
        fi

        echo "Trying ${url} ..."
        if git clone -b "$branch" "$url" "$dest"; then
            echo "Cloned ${target} via ${host}."
            return 0
        fi

        echo "importer: clone via ${host} failed" >&2
        if [[ -e "$dest" ]]; then
            rm -rf "$dest"
        fi
    done < <(_get_github_hosts)

    echo "importer: failed to clone ${target} via: ${tried:-<none>}" >&2
    return 1
}
