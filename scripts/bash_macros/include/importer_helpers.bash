#!/usr/bin/bash

# Private helpers for importer (short names). Bound to importer::_* via helpers_list.bash.

_get_importer_url() {
    case "$1" in
        transporter) printf '%s\n' "git@github.com:bafaurazan/transporter.git" ;;
        notaura_ws) printf '%s\n' "git@github.com:TheNotAura/notaura_ws.git" ;;
        *) return 1 ;;
    esac
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
    local url branch dest

    if ! load::_has_workspace_root; then
        echo "importer: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi

    url="$(_get_importer_url "$target")" || {
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
    git clone -b "$branch" "$url" "$dest"
}
