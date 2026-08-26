#!/usr/bin/bash

# Optional GUI over SSH: auto-select DISPLAY and XAUTHORITY for local X11 sockets.
# Disable with: export ROS2_AUTO_LOCAL_DISPLAY=0

is_auto_local_display_enabled() {
    [[ "${ROS2_AUTO_LOCAL_DISPLAY:-1}" != "0" ]]
}

has_x11_socket_for_display() {
    local display_candidate="$1"
    local x_socket="/tmp/.X11-unix/X${display_candidate#:}"
    [[ -S "$x_socket" ]]
}

has_xauthority() {
    [[ -n "${XAUTHORITY:-}" ]]
}

has_display() {
    [[ -n "${DISPLAY:-}" ]]
}

is_local_display() {
    case "${DISPLAY:-}" in
        :0|:1) return 0 ;;
        *) return 1 ;;
    esac
}

set_xauthority_from_local_candidates() {
    local cand
    shopt -s nullglob
    for cand in \
        "${HOME}/.Xauthority" \
        "/run/user/$(id -u)/gdm/Xauthority" \
        "/run/user/$(id -u)/lightdm/xauthority" \
        "/var/lib/lightdm-data/${USER}/.Xauthority" \
        /run/user/"$(id -u)"/.mutter-Xwaylandauth.* \
        /run/user/"$(id -u)"/xauth_*
    do
        [[ -s "$cand" ]] || continue
        export XAUTHORITY="$cand"
        shopt -u nullglob
        return 0
    done
    shopt -u nullglob
    return 1
}

set_local_display_if_available() {
    local display_candidate

    is_auto_local_display_enabled || return 0

    if ! has_display; then
        for display_candidate in :0 :1; do
            if has_x11_socket_for_display "$display_candidate"; then
                export DISPLAY="${display_candidate}"
                has_xauthority || set_xauthority_from_local_candidates || true
                return 0
            fi
        done
        return 0
    fi

    if ! has_xauthority && is_local_display; then
        set_xauthority_from_local_candidates || true
    fi
}
