#!/usr/bin/bash

# Optional GUI over SSH: auto-select DISPLAY and XAUTHORITY for local X11 sockets.
# Disable with: export ROS2_AUTO_LOCAL_DISPLAY=0

set_xauthority_from_local_candidates() {
    local _cand
    shopt -s nullglob
    for _cand in \
        "${HOME}/.Xauthority" \
        "/run/user/$(id -u)/gdm/Xauthority" \
        "/run/user/$(id -u)/lightdm/xauthority" \
        "/var/lib/lightdm-data/${USER}/.Xauthority" \
        /run/user/"$(id -u)"/.mutter-Xwaylandauth.* \
        /run/user/"$(id -u)"/xauth_*
    do
        [[ -s "$_cand" ]] || continue
        export XAUTHORITY="$_cand"
        shopt -u nullglob
        return 0
    done
    shopt -u nullglob
    return 1
}

set_local_display_if_available() {
    local display_candidate
    local x_socket

    [[ "${ROS2_AUTO_LOCAL_DISPLAY:-1}" != "0" ]] || return 0

    if [[ -z "${DISPLAY:-}" ]]; then
        for display_candidate in :0 :1; do
            x_socket="/tmp/.X11-unix/X${display_candidate#:}"
            if [[ -S "$x_socket" ]]; then
                export DISPLAY="${display_candidate}"
                [[ -n "${XAUTHORITY:-}" ]] || set_xauthority_from_local_candidates || true
                return 0
            fi
        done
        return 0
    fi

    if [[ -z "${XAUTHORITY:-}" ]]; then
        case "${DISPLAY}" in
            :0|:1) set_xauthority_from_local_candidates || true ;;
        esac
    fi
}
