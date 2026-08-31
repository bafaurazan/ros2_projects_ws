#!/usr/bin/bash

# Private helpers for importer (short names). Bound to importer::_* via helpers_list.bash.

_get_importer_repo_path() {
    case "$1" in
        transporter) printf '%s\n' "bafaurazan/transporter" ;;
        notaura_ws) printf '%s\n' "TheNotAura/notaura_ws" ;;
        *) return 1 ;;
    esac
}

_get_importer_github_hosts() {
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

_get_importer_branch() {
    case "$1" in
        transporter|notaura_ws) printf '%s\n' "develop" ;;
        *) return 1 ;;
    esac
}

_get_importer_dir() {
    local target="$1"
    printf '%s\n' "${ROS2_PROJECTS_WS_ROOT:?ROS2_PROJECTS_WS_ROOT is not set}/src/${target}"
}

_list_importer_targets() {
    echo "Usage: importer <target>"
    echo "Targets:"
    echo "  transporter    ${ROS2_PROJECTS_WS_ROOT:-<workspace>}/src/transporter"
    echo "  notaura_ws     ${ROS2_PROJECTS_WS_ROOT:-<workspace>}/src/notaura_ws"
}

_ensure_importer_repo() {
    local target="$1"
    local repo_path branch dest host url tried=""

    if ! load::_has_workspace_root; then
        echo "importer: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi

    repo_path="$(_get_importer_repo_path "$target")" || {
        echo "importer: unknown target '$target'" >&2
        _list_importer_targets >&2
        return 1
    }
    branch="$(_get_importer_branch "$target")" || return 1
    dest="$(_get_importer_dir "$target")"

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
    done < <(_get_importer_github_hosts)

    echo "importer: failed to clone ${target} via: ${tried:-<none>}" >&2
    return 1
}
