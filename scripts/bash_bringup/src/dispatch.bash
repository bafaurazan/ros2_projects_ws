#!/usr/bin/bash

# Compose humble|jazzy|macros. Sourced by launch/bringup.bash after helpers.

_run_container() {
    exec "${ROS2_PROJECTS_WS_ROOT}/scripts/bash_container/launch/runtime_dispatch.bash" "$_mode" "$_runtime"
}

_run_macros() {
    if _has_runtime "$_runtime"; then
        _fail "mode 'macros' does not take extra arguments."
        return 1
    fi

    local macros_session="${ROS2_PROJECTS_WS_ROOT}/scripts/bash_bringup/src/macros_session.bash"

    if _is_sourced; then
        # shellcheck disable=SC1090
        source "$macros_session"
        local status=$?
        _cleanup
        return "$status"
    fi

    export _MACROS_SETUP_AS_RCFILE=1
    exec bash --rcfile "$macros_session" -i
}

_dispatch() {
    if _is_distro_mode "$_mode"; then
        _run_container
        return 0
    fi

    case "$_mode" in
        macros)
            _run_macros
            return $?
            ;;
        "")
            _fail "missing mode."
            return 1
            ;;
        *)
            _fail "unknown mode '${_mode}'."
            return 1
            ;;
    esac
}
