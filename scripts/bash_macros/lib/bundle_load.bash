#!/usr/bin/bash

# Sourced from a bundle's launch/macros.bash only. Loads that bundle's
# include/*_helpers.bash (known root names first, then the rest) and src/*.bash.
# Do not source from src/. Skips completion (lives in lib/completion.bash).

_bundle_load_caller="${BASH_SOURCE[1]:-}"
if [[ -z "$_bundle_load_caller" || "${_bundle_load_caller##*/}" != "macros.bash" ]]; then
    echo "bundle_load: source from launch/macros.bash only" >&2
    unset _bundle_load_caller
    return 1
fi

_bundle_dir="$(cd "$(dirname "$_bundle_load_caller")/.." && pwd)" || return 1
_bundle_include="${_bundle_dir}/include"
_bundle_src="${_bundle_dir}/src"
_bundle_helper=
_bundle_helper_name=
_bundle_helper_stem=
_bundle_src_file=
_bundle_src_name=
declare -A _bundle_seen_helpers=()

# Enforce file-naming readability: src/<macro>.bash must define <macro>, and
# include/<macro>_helpers.bash must have a matching src/<macro>.bash. Cross-calling
# helpers across macros (e.g. cbuild → build::) is allowed and not checked here.
if [[ -d "$_bundle_include" ]]; then
    shopt -s nullglob
    for _bundle_helper in "$_bundle_include"/*_helpers.bash; do
        _bundle_helper_name="${_bundle_helper##*/}"
        _bundle_helper_stem="${_bundle_helper_name%_helpers.bash}"
        if [[ ! -f "${_bundle_src}/${_bundle_helper_stem}.bash" ]]; then
            echo "bundle_load: include/${_bundle_helper_name} has no matching src/${_bundle_helper_stem}.bash" >&2
            shopt -u nullglob
            unset _bundle_load_caller _bundle_dir _bundle_include _bundle_src
            unset _bundle_helper _bundle_helper_name _bundle_helper_stem _bundle_src_file _bundle_src_name
            unset _bundle_seen_helpers
            return 1
        fi
    done
    shopt -u nullglob
fi

if [[ -d "$_bundle_include" ]]; then
    for _bundle_helper_name in load_macros_helpers.bash build_helpers.bash importer_helpers.bash diag_helpers.bash; do
        _bundle_helper="${_bundle_include}/${_bundle_helper_name}"
        if [[ -f "$_bundle_helper" ]]; then
            # shellcheck disable=SC1090
            source "$_bundle_helper"
            _bundle_seen_helpers["$_bundle_helper_name"]=1
        fi
    done
    shopt -s nullglob
    for _bundle_helper in "$_bundle_include"/*_helpers.bash; do
        _bundle_helper_name="${_bundle_helper##*/}"
        [[ -n ${_bundle_seen_helpers[$_bundle_helper_name]:-} ]] && continue
        # shellcheck disable=SC1090
        source "$_bundle_helper"
    done
    shopt -u nullglob
fi

if [[ -d "$_bundle_src" ]]; then
    shopt -s nullglob
    for _bundle_src_file in "$_bundle_src"/*.bash; do
        # shellcheck disable=SC1090
        source "$_bundle_src_file"
        _bundle_src_name="${_bundle_src_file##*/}"
        _bundle_src_name="${_bundle_src_name%.bash}"
        if ! declare -F "$_bundle_src_name" >/dev/null 2>&1; then
            echo "bundle_load: src/${_bundle_src_name}.bash must define function ${_bundle_src_name}" >&2
            shopt -u nullglob
            unset _bundle_load_caller _bundle_dir _bundle_include _bundle_src
            unset _bundle_helper _bundle_helper_name _bundle_helper_stem _bundle_src_file _bundle_src_name
            unset _bundle_seen_helpers
            return 1
        fi
    done
    shopt -u nullglob
fi

unset _bundle_load_caller _bundle_dir _bundle_include _bundle_src
unset _bundle_helper _bundle_helper_name _bundle_helper_stem _bundle_src_file _bundle_src_name
unset _bundle_seen_helpers
