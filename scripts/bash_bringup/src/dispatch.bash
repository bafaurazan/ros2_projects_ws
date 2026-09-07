#!/usr/bin/bash

# Compose humble|jazzy|macros. Sourced by launch/bringup.bash after helpers.

bringup::_run_container() {
    exec "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_container/launch/runtime_dispatch.bash" "$_mode" "$_runtime"
}

bringup::_run_macros() {
    if bringup::_has_runtime "$_runtime"; then
        bringup::_fail "mode 'macros' does not take extra arguments."
        return 1
    fi

    local macros_session="${ROS2_PROJECTS_WS_ROOT}/scripts/bash_bringup/src/macros_session.bash"

    if bringup::_is_sourced; then
        # shellcheck disable=SC1090
        source "$macros_session"
        local status=$?
        bringup::_cleanup
        return "$status"
    fi

    export _MACROS_SETUP_AS_RCFILE=1
    exec bash --rcfile "$macros_session" -i
}

bringup::_dispatch() {
    if bringup::_is_distro_mode "$_mode"; then
        bringup::_run_container
        return 0
    fi

    case "$_mode" in
        macros)
            bringup::_run_macros
            return $?
            ;;
        "")
            bringup::_fail "missing mode."
            return 1
            ;;
        *)
            bringup::_fail "unknown mode '${_mode}'."
            return 1
            ;;
    esac
}
