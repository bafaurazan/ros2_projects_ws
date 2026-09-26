#!/usr/bin/bash

# Distrobox backend functions. Sourced by launch/backends/run_distrobox.bash.

# ==============================================================================
# Predicates / getters / setters
# ==============================================================================

env::_is_supported_ros2_distro() {
    [[ "$1" == "humble" || "$1" == "jazzy" ]]
}

env::_is_humble_distro() {
    [[ "$1" == "humble" ]]
}

env::_has_command() {
    command -v "$1" >/dev/null 2>&1
}

env::_has_nvidia_gpu() {
    env::_has_command lspci && lspci | grep -qi nvidia
}

env::_is_verbose() {
    case "${ROS2_PROJECTS_WS_VERBOSE:-}" in
        1 | true | TRUE | yes | YES | on | ON) return 0 ;;
        *) return 1 ;;
    esac
}

env::_has_fuse_overlay_config() {
    local storage_conf="$1"
    [[ -f "$storage_conf" ]] && grep -q "fuse-overlayfs" "$storage_conf"
}

env::_has_distrobox_container() {
    distrobox list --no-color | tr -s ' ' | cut -d ' ' -f 3 | tail -n +2 | grep -q "^${CONTAINER_NAME}$"
}

env::_get_container_manager() {
    if [[ -n "${DBX_CONTAINER_MANAGER:-}" ]]; then
        printf '%s\n' "$DBX_CONTAINER_MANAGER"
        return 0
    fi
    if env::_has_command podman && podman container exists "$CONTAINER_NAME" 2>/dev/null; then
        printf '%s\n' "podman"
        return 0
    fi
    if env::_has_command docker && docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        printf '%s\n' "docker"
        return 0
    fi
    if env::_has_command podman; then
        printf '%s\n' "podman"
        return 0
    fi
    printf '%s\n' "docker"
}

env::_get_host_arch() {
    uname -m
}

env::_has_container_passwd_done() {
    local mgr="$1"
    "$mgr" exec "$CONTAINER_NAME" test -f /etc/passwd.done >/dev/null 2>&1
}

env::_has_container_setup_keepalive() {
    local mgr="$1"
    local pid
    pid="$("$mgr" inspect --type container --format '{{.State.Pid}}' "$CONTAINER_NAME" 2>/dev/null || true)"
    [[ -n "$pid" && "$pid" != "0" ]] || return 1
    pgrep -P "$pid" -a 2>/dev/null | grep -qE '(^|[ /])sleep( |$)'
}

env::_get_container_status() {
    local mgr="$1"
    "$mgr" inspect --type container --format '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || printf '%s\n' "missing"
}

env::_is_busy_setup_child() {
    # Long apt/dpkg with unchanged cmdline is progress, not a stall.
    [[ "$1" =~ apt-get|[^[:alnum:]]apt[[:space:]]|dpkg|unminimize|find[[:space:]]|mount[[:space:]] ]]
}

env::_get_setup_progress_snapshot() {
    local mgr="$1"
    local pid child nvidia_mounts last_distrobox passwd_done keepalive log_tail
    pid="$("$mgr" inspect --type container --format '{{.State.Pid}}' "$CONTAINER_NAME" 2>/dev/null || echo 0)"
    child="$(pgrep -P "$pid" -a 2>/dev/null | head -1 | tr '|\"' ' ' || true)"
    # Prefer live mount table over re-scanning full journal (huge with --verbose).
    nvidia_mounts="$("$mgr" exec "$CONTAINER_NAME" sh -c 'mount 2>/dev/null | grep -c nvidia || true' 2>/dev/null || echo 0)"
    nvidia_mounts="${nvidia_mounts:-0}"
    log_tail="$("$mgr" logs --tail 80 "$CONTAINER_NAME" 2>/dev/null || true)"
    last_distrobox="$(printf '%s\n' "$log_tail" | grep '^distrobox:' | tail -1 | tr '|\"' ' ' || true)"
    passwd_done=0
    keepalive=0
    env::_has_container_passwd_done "$mgr" && passwd_done=1
    env::_has_container_setup_keepalive "$mgr" && keepalive=1
    printf '%s\n' "$passwd_done|$keepalive|${nvidia_mounts}|$pid|$child|$last_distrobox"
}

env::_get_setup_phase() {
    local passwd_done="$1"
    local nvidia_mounts="$2"
    local child="$3"
    local last_distrobox="$4"

    if [[ "$passwd_done" == "1" ]]; then
        printf '%s\n' "Finishing setup"
        return 0
    fi
    if [[ "$nvidia_mounts" -gt 0 ]] || [[ "$child" =~ find[[:space:]].*nvidia ]] || \
        [[ "$last_distrobox" == *nvidia* ]]; then
        printf '%s\n' "Setting up NVIDIA"
        return 0
    fi
    if [[ "$child" =~ apt-get|dpkg|unminimize ]]; then
        printf '%s\n' "Installing packages"
        return 0
    fi
    if [[ "$last_distrobox" == *"Installing basic packages"* ]] || \
        [[ "$last_distrobox" == *"additional packages"* ]]; then
        printf '%s\n' "Installing packages"
        return 0
    fi
    printf '%s\n' "Starting container setup"
}

env::_format_setup_elapsed() {
    local seconds="$1"
    if [[ "$seconds" -lt 60 ]]; then
        printf '%ss\n' "$seconds"
        return 0
    fi
    printf '%sm%02ds\n' "$((seconds / 60))" "$((seconds % 60))"
}

env::_truncate_setup_detail() {
    local text="$1"
    local max="${2:-48}"
    text="$(printf '%s' "$text" | sed -E 's/^[0-9]+[[:space:]]+//')"
    if [[ ${#text} -gt "$max" ]]; then
        printf '%s...\n' "${text:0:$((max - 3))}"
        return 0
    fi
    printf '%s\n' "$text"
}

env::_get_setup_activity_detail() {
    local nvidia_mounts="$1"
    local child="$2"
    local last_distrobox="$3"

    if [[ -n "$child" ]]; then
        env::_truncate_setup_detail "$child" 48
        return 0
    fi
    if [[ "$nvidia_mounts" -gt 0 ]]; then
        printf 'mounts=%s\n' "$nvidia_mounts"
        return 0
    fi
    if [[ -n "$last_distrobox" ]]; then
        env::_truncate_setup_detail "${last_distrobox#distrobox: }" 48
        return 0
    fi
    printf '\n'
}

# Quiet mode: one overwriting status line. stalled_seconds >= 120 → still waiting hint.
# Sets _SETUP_STATUS_PREV_LINE in caller scope for non-TTY dedupe when provided via nameref-style global.
env::_print_setup_status_line() {
    local phase="$1"
    local detail="$2"
    local elapsed_label="$3"
    local stalled_seconds="$4"
    local line

    if [[ -n "$detail" ]]; then
        line="${phase} | ${detail} (${elapsed_label})"
    else
        line="${phase} (${elapsed_label})"
    fi
    if [[ "$stalled_seconds" -ge 120 ]]; then
        line="${line} — still waiting"
    fi

    if [[ -t 1 ]]; then
        printf '\r\033[K%s' "$line"
        return 0
    fi

    # Non-TTY: only emit when the activity text changes (ignore elapsed-only updates).
    local key="${phase}|${detail}|$((stalled_seconds >= 120))"
    if [[ "$key" != "${_SETUP_STATUS_PREV_KEY:-}" ]]; then
        printf '%s\n' "$line"
        _SETUP_STATUS_PREV_KEY="$key"
    fi
}

# First-start hang: distrobox-enter waits for container_setup_done in logs, but entrypoint
# always runs with --verbose (set -x on stderr) while done-marker is on block-buffered
# stdout — so UI sticks on nvidia even after /etc/passwd.done + keepalive.
env::_ensure_container_setup_ready() {
    local mgr status stalled_ticks=0
    local prev_progress="" progress snap passwd_done keepalive nvidia_mounts pid child last_distrobox
    local phase detail elapsed_label start_ts now_ts elapsed stalled_seconds
    local prev_verbose_key="" verbose_key
    local use_tty=0
    # sleep 0.2 → ~5 ticks per second
    local ticks_per_sec=5

    [[ -t 1 ]] && use_tty=1

    mgr="$(env::_get_container_manager)"
    status="$(env::_get_container_status "$mgr")"

    if [[ "$status" != "running" ]]; then
        echo "▶️  Starting container ($CONTAINER_NAME) via $mgr..."
        if ! "$mgr" start "$CONTAINER_NAME" >/dev/null; then
            echo "❌ Failed to start container with $mgr."
            return 1
        fi
    fi

    if env::_has_container_passwd_done "$mgr" && env::_has_container_setup_keepalive "$mgr"; then
        echo "✅ Container setup already complete."
        return 0
    fi

    if env::_is_verbose; then
        echo "⏳ First-boot setup (verbose)..."
    fi

    start_ts="$(date +%s)"
    _SETUP_STATUS_PREV_KEY=""

    while true; do
        status="$(env::_get_container_status "$mgr")"
        if [[ "$status" != "running" ]]; then
            [[ "$use_tty" -eq 1 ]] && ! env::_is_verbose && printf '\r\033[K'
            echo "❌ Container left running state during setup ($status)."
            return 1
        fi

        snap="$(env::_get_setup_progress_snapshot "$mgr")"
        IFS='|' read -r passwd_done keepalive nvidia_mounts pid child last_distrobox <<<"$snap"
        nvidia_mounts="${nvidia_mounts:-0}"
        progress="${passwd_done}|${keepalive}|${nvidia_mounts}|${pid}|${child}"

        now_ts="$(date +%s)"
        elapsed=$((now_ts - start_ts))
        elapsed_label="$(env::_format_setup_elapsed "$elapsed")"

        if [[ "$passwd_done" == "1" && "$keepalive" == "1" ]]; then
            if [[ "$use_tty" -eq 1 ]] && ! env::_is_verbose; then
                printf '\r\033[K'
            fi
            echo "✅ Container setup complete."
            return 0
        fi

        if env::_is_busy_setup_child "$child"; then
            stalled_ticks=0
        elif [[ "$progress" == "$prev_progress" ]]; then
            stalled_ticks=$((stalled_ticks + 1))
        else
            stalled_ticks=0
        fi
        prev_progress="$progress"
        stalled_seconds=$((stalled_ticks / ticks_per_sec))

        phase="$(env::_get_setup_phase "$passwd_done" "$nvidia_mounts" "$child" "$last_distrobox")"
        detail="$(env::_get_setup_activity_detail "$nvidia_mounts" "$child" "$last_distrobox")"

        if env::_is_verbose; then
            verbose_key="${phase}|${nvidia_mounts}|${passwd_done}|${keepalive}|${detail}|$((stalled_seconds >= 120))"
            if [[ "$verbose_key" != "$prev_verbose_key" ]]; then
                printf '   %s | mounts=%s passwd.done=%s keepalive=%s | %s | %s' \
                    "$phase" "$nvidia_mounts" "$passwd_done" "$keepalive" \
                    "${detail:-none}" "$elapsed_label"
                if [[ "$stalled_seconds" -ge 120 ]]; then
                    printf ' — still waiting'
                fi
                printf '\n'
                prev_verbose_key="$verbose_key"
            fi
        else
            env::_print_setup_status_line "$phase" "$detail" "$elapsed_label" "$stalled_seconds"
        fi

        sleep 0.2
    done
}

env::_get_default_ros2_image() {
    local distro="$1"
    local arch
    arch="$(env::_get_host_arch)"

    case "$arch" in
        x86_64|amd64) printf '%s\n' "docker.io/osrf/ros:${distro}-desktop-full" ;;
        aarch64|arm64) printf '%s\n' "docker.io/arm64v8/ros:${distro}-ros-base" ;;
        armv7l|armhf)  printf '%s\n' "docker.io/arm32v7/ros:${distro}-ros-base" ;;
        *) return 1 ;;
    esac
}

env::_set_ros2_image_for_host_arch() {
    local image
    if ! image="$(env::_get_default_ros2_image "$ROS_DISTRO")"; then
        echo "❌ Error: Unsupported architecture '$(env::_get_host_arch)'."
        exit 1
    fi
    ROS2_IMAGE="${ROS_DOCKER_IMAGE:-$image}"
}

# ==============================================================================
# Setup steps
# ==============================================================================

env::_validate_and_set_architecture() {
    if ! env::_is_supported_ros2_distro "$ROS_DISTRO"; then
        echo "❌ Error: Unsupported ROS distro: $ROS_DISTRO"
        echo "Usage: ./scripts/setup.bash [-v|--verbose] [humble|jazzy [prod]|macros]"
        exit 1
    fi

    if ! env::_is_humble_distro "$ROS_DISTRO"; then
        ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES unminimize"
    fi

    env::_set_ros2_image_for_host_arch
}

env::_install_host_dependencies() {
    if ! env::_has_command distrobox; then
        echo "❌ Error: distrobox is not installed (or not in PATH)."
        exit 1
    fi

    if ! env::_has_command flatpak; then
        echo "🛠️ Installing flatpak..."
        sudo apt-get update && sudo apt-get install -y flatpak || echo "Install flatpak manually."
    fi
}

env::_apply_podman_rootless_fix() {
    env::_has_command podman || return 0

    local storage_conf="$HOME/.config/containers/storage.conf"

    if ! env::_has_command fuse-overlayfs; then
        echo "🛠️ Installing fuse-overlayfs (required by Podman)..."
        sudo apt-get update && sudo apt-get install -y fuse-overlayfs || true
    fi

    if ! env::_has_fuse_overlay_config "$storage_conf"; then
        echo "⚙️ Applying Podman storage configuration..."
        mkdir -p "$(dirname "$storage_conf")"
        cat <<EOF > "$storage_conf"
[storage]
driver = "overlay"

[storage.options.overlay]
mount_program = "/usr/bin/fuse-overlayfs"
EOF
        podman system reset -f >/dev/null 2>&1 || true
        echo "✅ Podman fix applied."
    fi
}

env::_setup_container_home() {
    if [[ ! -d "$DISTROBOX_HOME" ]]; then
        mkdir -p "$DISTROBOX_HOME"
        touch "$DISTROBOX_HOME/.sudo_as_admin_successful"
    fi

    if [[ ! -e "$DISTROBOX_HOME/.gitconfig" && -e "$HOME/.gitconfig" ]]; then
        ln -s "$HOME/.gitconfig" "$DISTROBOX_HOME/.gitconfig"
    fi

    if [[ ! -e "$DISTROBOX_HOME/.ssh" && -e "$HOME/.ssh" ]]; then
        ln -s "$HOME/.ssh" "$DISTROBOX_HOME/.ssh"
    fi
}

env::_ensure_container() {
    env::_has_distrobox_container && return 0

    echo "🚀 Creating Distrobox instance ($CONTAINER_NAME)..."
    echo "📦 Using image: $ROS2_IMAGE"

    local nvidia_flag=""
    if env::_has_nvidia_gpu; then
        nvidia_flag="--nvidia"
        echo "🎮 NVIDIA GPU detected — creating with --nvidia"
    fi

    local init_hooks="chsh -s /usr/bin/bash $USER"
    if ! env::_is_humble_distro "$ROS_DISTRO"; then
        init_hooks="$init_hooks && (yes | sudo unminimize)"
    fi

    # shellcheck disable=SC2086
    distrobox create \
        --image "$ROS2_IMAGE" \
        --yes \
        --name "$CONTAINER_NAME" \
        --home "$DISTROBOX_HOME" \
        --additional-packages "$ADDITIONAL_PACKAGES" \
        --absolutely-disable-root-password-i-am-really-positively-sure \
        --init-hooks "$init_hooks" \
        $nvidia_flag \
        --no-entry \
        --additional-flags "--mount type=bind,source=/dev/bus/usb,target=/dev/bus/usb"
}

env::_configure_container_internals() {
    # Container must already be running with setup done — otherwise distrobox-enter
    # blocks forever waiting for a log marker that stdout buffering can drop.
    local apt_quiet_redirect=""
    if ! env::_is_verbose; then
        apt_quiet_redirect=">/dev/null 2>&1"
    fi

    distrobox enter "$CONTAINER_NAME" -- bash -lc "
        bashrc=\"\$HOME/.bashrc\"
        # Always refresh the workspace env hook (path may change across refactors).
        if grep -q 'BEGIN ROS2_PROJECTS_WS_ENV' \"\$bashrc\" 2>/dev/null; then
            sed -i '/# BEGIN ROS2_PROJECTS_WS_ENV/,/# END ROS2_PROJECTS_WS_ENV/d' \"\$bashrc\"
        fi
        cat >> \"\$bashrc\" <<EOF

# BEGIN ROS2_PROJECTS_WS_ENV
export ROS_DISTRO=\"$ROS_DISTRO\"
if [ -f \"$CONTAINER_SESSION_SETUP\" ]; then
    source \"$CONTAINER_SESSION_SETUP\"
fi
# END ROS2_PROJECTS_WS_ENV
EOF

        # Install CycloneDDS RMW
        if command -v apt-get >/dev/null 2>&1; then
            pkg=\"ros-${ROS_DISTRO}-rmw-cyclonedds-cpp\"
            if ! dpkg -s \"\$pkg\" >/dev/null 2>&1; then
                echo \"📦 Installing \$pkg...\"
                if ! sudo apt-get update ${apt_quiet_redirect}; then
                    echo \"⚠️ Warning: apt-get update failed.\"
                elif ! sudo apt-get install -y \"\$pkg\" ${apt_quiet_redirect}; then
                    echo \"⚠️ Warning: Failed to install \$pkg.\"
                fi
            fi
        fi
    "
}

env::_enter_container() {
    echo "✅ Environment ready. Entering container..."
    distrobox enter "$CONTAINER_NAME" -- /usr/bin/bash -i
}

env::_run_distrobox() {
    env::_validate_and_set_architecture
    env::_install_host_dependencies
    env::_apply_podman_rootless_fix
    env::_setup_container_home
    env::_ensure_container
    env::_ensure_container_setup_ready
    env::_configure_container_internals
    env::_enter_container
}
