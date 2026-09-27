#!/usr/bin/bash

# Private helpers for importer. Bodies are importer::_*.

importer::_get_config_path() {
    local bundle_dir
    bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    printf '%s\n' "${bundle_dir}/config/repos/importer.yaml"
}

# Resolve target name to destination key (path under repositories:).
# Matches full key or basename of key.
importer::_resolve_dest_key() {
    local target="$1"
    local file key
    file="$(importer::_get_config_path)"
    [[ -f "$file" ]] || return 1
    while IFS= read -r key; do
        [[ -n "$key" ]] || continue
        if [[ "$key" == "$target" || "${key##*/}" == "$target" ]]; then
            printf '%s\n' "$key"
            return 0
        fi
    done < <(importer::_list_dest_keys)
    return 1
}

importer::_list_dest_keys() {
    local file
    file="$(importer::_get_config_path)"
    [[ -f "$file" ]] || return 0
    awk '
        /^repositories:[[:space:]]*\{\}[[:space:]]*$/ { exit }
        /^repositories:/ { in_repos = 1; next }
        in_repos && /^[^[:space:]#]/ { exit }
        in_repos && /^  [^[:space:]#][^:]*:/ {
            key = $0
            sub(/^  /, "", key)
            sub(/:.*$/, "", key)
            if (key != "") print key
        }
    ' "$file"
}

# field: url | version
importer::_get_repo_field() {
    local dest_key="$1"
    local field="$2"
    local file
    file="$(importer::_get_config_path)"
    [[ -f "$file" ]] || return 1
    awk -v key="$dest_key" -v field="$field" '
        /^repositories:[[:space:]]*\{\}[[:space:]]*$/ { exit }
        /^repositories:/ { in_repos = 1; next }
        in_repos && /^[^[:space:]#]/ { exit }
        in_repos && /^  [^[:space:]#][^:]*:/ {
            k = $0
            sub(/^  /, "", k)
            sub(/:.*$/, "", k)
            in_entry = (k == key)
            next
        }
        in_entry && $1 == field ":" {
            val = $0
            sub(/^[[:space:]]*[^:]+:[[:space:]]*/, "", val)
            sub(/[[:space:]]*$/, "", val)
            print val
            found = 1
            exit
        }
        END { exit !found }
    ' "$file"
}

importer::_get_github_hosts() {
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

importer::_get_clone_url() {
    importer::_get_repo_field "$1" url
}

importer::_get_branch() {
    importer::_get_repo_field "$1" version
}

importer::_get_clone_dir() {
    local dest_key="$1"
    printf '%s\n' "${ROS2_PROJECTS_WS_ROOT:?ROS2_PROJECTS_WS_ROOT is not set}/${dest_key}"
}

importer::_list_targets() {
    local file dest_key
    file="$(importer::_get_config_path)"
    echo "Usage: importer <target>"
    echo "Targets (from ${file}):"
    if [[ ! -f "$file" ]]; then
        echo "  (config file missing)"
        return 0
    fi
    while IFS= read -r dest_key; do
        [[ -n "$dest_key" ]] || continue
        echo "  ${dest_key##*/}    ${ROS2_PROJECTS_WS_ROOT:-<workspace>}/${dest_key}"
    done < <(importer::_list_dest_keys)
}

# Rewrite git@github.com: → git@${host}: when host is not github.com.
importer::_url_for_host() {
    local url="$1"
    local host="$2"
    if [[ "$host" == "github.com" ]]; then
        printf '%s\n' "$url"
        return 0
    fi
    printf '%s\n' "${url/git@github.com:/git@${host}:}"
}

importer::_ensure_repo() {
    local target="$1"
    local dest_key url branch dest host clone_url tried=""

    if ! load_macros::_has_workspace_root; then
        echo "importer: ROS2_PROJECTS_WS_ROOT is not set" >&2
        return 1
    fi

    dest_key="$(importer::_resolve_dest_key "$target")" || {
        echo "importer: unknown target '$target'" >&2
        importer::_list_targets >&2
        return 1
    }
    url="$(importer::_get_clone_url "$dest_key")" || {
        echo "importer: missing url for '$dest_key'" >&2
        return 1
    }
    branch="$(importer::_get_branch "$dest_key")" || {
        echo "importer: missing version for '$dest_key'" >&2
        return 1
    }
    dest="$(importer::_get_clone_dir "$dest_key")"

    mkdir -p "$(dirname "$dest")" || return 1

    if [[ -d "${dest}/.git" ]]; then
        echo "${dest_key##*/} already present at ${dest} — ignoring command"
        return 2
    fi

    if [[ -e "$dest" ]]; then
        echo "importer: ${dest} exists but is not a git repository" >&2
        return 1
    fi

    echo "Cloning ${dest_key##*/} (${branch})..."
    while IFS= read -r host; do
        [[ -n "$host" ]] || continue
        clone_url="$(importer::_url_for_host "$url" "$host")"
        if [[ -n "$tried" ]]; then
            tried+=", ${host}"
        else
            tried="$host"
        fi

        echo "Trying ${clone_url} ..."
        if git clone -b "$branch" "$clone_url" "$dest"; then
            echo "Cloned ${dest_key##*/} via ${host}."
            return 0
        fi

        echo "importer: clone via ${host} failed" >&2
        if [[ -e "$dest" ]]; then
            rm -rf "$dest"
        fi
    done < <(importer::_get_github_hosts)

    echo "importer: failed to clone ${dest_key##*/} via: ${tried:-<none>}" >&2
    return 1
}
