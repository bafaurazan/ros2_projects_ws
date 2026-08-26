#!/usr/bin/bash

# Bind short helper names to ns::_* entry points (C++-like namespace look).
# Short names stay defined so helpers can call each other; do not unset them.

[[ -n "${_MACROS_HELPERS_LIST_LOADED:-}" ]] && return
_MACROS_HELPERS_LIST_LOADED=1

_helpers_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_helpers_dir}/diag_helpers.bash"
# shellcheck disable=SC1091
source "${_helpers_dir}/build_helpers.bash"
# shellcheck disable=SC1091
source "${_helpers_dir}/sync_helpers.bash"

_macros_bind_namespace() {
    local namespace="$1"
    shift
    local short
    for short in "$@"; do
        # shellcheck disable=SC2329
        eval "${namespace}::${short}() { ${short} \"\$@\"; }"
    done
}

_macros_bind_namespace diag \
    _has_command \
    _print_system \
    _print_tool \
    _print_tools \
    _print_environment \
    _get_expected_cyclone_uri \
    _has_cyclone_xml \
    _is_env_loaded \
    _print_checks \
    _get_macros_index \
    _has_macros_index \
    _print_macros

_macros_bind_namespace build \
    _has_src_dir \
    _get_ros_distro \
    _get_artifacts_dir \
    _get_pip_python \
    _is_venv_python \
    _has_externally_managed_python \
    _collect_rosdep_paths \
    _install_apt_packages \
    _install_pip_requirements \
    _source_install_overlay

_macros_bind_namespace sync \
    _get_repo_from_path \
    _has_workspace_root \
    _get_dest_root \
    _find_sources \
    _extract_functions \
    _copy_bundle \
    _has_nounset \
    _source_cache

unset -f _macros_bind_namespace
unset _helpers_dir
