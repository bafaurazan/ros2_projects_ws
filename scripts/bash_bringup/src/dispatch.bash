#!/usr/bin/bash

# Compose humble|jazzy|macros. Sourced by launch/bringup.bash after helpers.
# Hands off all modes to bash_env.

bringup::_dispatch() {
    local env_dispatch="${ROS2_PROJECTS_WS_ROOT}/scripts/bash_env/launch/runtime_dispatch.bash"

    if [[ -z "${_mode:-}" ]]; then
        bringup::_fail "missing mode."
        return 1
    fi

    if bringup::_is_sourced; then
        # shellcheck disable=SC1090
        source "$env_dispatch" "$_mode" "$_runtime"
        local status=$?
        bringup::_cleanup
        return "$status"
    fi

    exec "$env_dispatch" "$_mode" "$_runtime"
}
