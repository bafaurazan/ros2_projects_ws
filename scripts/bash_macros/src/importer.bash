#!/usr/bin/bash

# Usage: importer <transporter|notaura_ws>

_macros_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${_macros_dir}/include/helpers_list.bash"
unset _macros_dir

importer() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        importer::_list_importer_targets
        return 1
    fi

    local status=0
    importer::_ensure_importer_repo "$target" || status=$?
    [[ "$status" -eq 2 ]] && return 0
    [[ "$status" -ne 0 ]] && return 1

    if declare -F load_macros >/dev/null 2>&1; then
        load_macros || return 1
    else
        echo "importer: load_macros is not available" >&2
        return 1
    fi

    echo "Imported ${target}. Macros reloaded."
}
