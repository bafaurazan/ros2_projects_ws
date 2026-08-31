#!/usr/bin/env bash

set -euo pipefail

# Distrobox backend: create/enter ros2_projects_ws_<distro> and hook the container session.

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_dir}/../../config/distrobox_config.bash" "${1:-}"

# ==============================================================================
# Predicates / getters / setters
# ==============================================================================

_is_supported_ros2_distro() {
    [[ "$1" == "humble" || "$1" == "jazzy" ]]
}

_is_humble_distro() {
    [[ "$1" == "humble" ]]
}

_has_command() {
    command -v "$1" >/dev/null 2>&1
}

_has_nvidia_gpu() {
    _has_command lspci && lspci | grep -qi nvidia
}

_has_fuse_overlay_config() {
    local storage_conf="$1"
    [[ -f "$storage_conf" ]] && grep -q "fuse-overlayfs" "$storage_conf"
}

_has_distrobox_container() {
    distrobox list --no-color | tr -s ' ' | cut -d ' ' -f 3 | tail -n +2 | grep -q "^${CONTAINER_NAME}$"
}

_get_host_arch() {
    uname -m
}

_get_default_ros2_image() {
    local distro="$1"
    local arch
    arch="$(_get_host_arch)"

    case "$arch" in
        x86_64|amd64) printf '%s\n' "docker.io/osrf/ros:${distro}-desktop-full" ;;
        aarch64|arm64) printf '%s\n' "docker.io/arm64v8/ros:${distro}-ros-base" ;;
        armv7l|armhf)  printf '%s\n' "docker.io/arm32v7/ros:${distro}-ros-base" ;;
        *) return 1 ;;
    esac
}

_set_ros2_image_for_host_arch() {
    local image
    if ! image="$(_get_default_ros2_image "$ROS_DISTRO")"; then
        echo "❌ Error: Unsupported architecture '$(_get_host_arch)'."
        exit 1
    fi
    ROS2_IMAGE="${ROS_DOCKER_IMAGE:-$image}"
}

# ==============================================================================
# Setup steps
# ==============================================================================

_validate_and_set_architecture() {
    if ! _is_supported_ros2_distro "$ROS_DISTRO"; then
        echo "❌ Error: Unsupported ROS distro: $ROS_DISTRO"
        echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]"
        exit 1
    fi

    if ! _is_humble_distro "$ROS_DISTRO"; then
        ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES unminimize"
    fi

    _set_ros2_image_for_host_arch
}

_install_host_dependencies() {
    if ! _has_command distrobox; then
        echo "❌ Error: distrobox is not installed (or not in PATH)."
        exit 1
    fi

    if ! _has_command flatpak; then
        echo "🛠️ Installing flatpak..."
        sudo apt-get update && sudo apt-get install -y flatpak || echo "Install flatpak manually."
    fi
}

_apply_podman_rootless_fix() {
    _has_command podman || return 0

    local storage_conf="$HOME/.config/containers/storage.conf"

    if ! _has_command fuse-overlayfs; then
        echo "🛠️ Installing fuse-overlayfs (required by Podman)..."
        sudo apt-get update && sudo apt-get install -y fuse-overlayfs || true
    fi

    if ! _has_fuse_overlay_config "$storage_conf"; then
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

_setup_container_home() {
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

_ensure_container() {
    _has_distrobox_container && return 0

    echo "🚀 Creating Distrobox instance ($CONTAINER_NAME)..."
    echo "📦 Using image: $ROS2_IMAGE"

    local nvidia_flag=""
    if _has_nvidia_gpu; then
        nvidia_flag="--nvidia"
    fi

    local init_hooks="chsh -s /usr/bin/bash $USER"
    if ! _is_humble_distro "$ROS_DISTRO"; then
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

_configure_container_internals() {
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
                echo \"📦 Installing \$pkg inside the container...\"
                sudo apt-get update
                sudo apt-get install -y \"\$pkg\" || echo \"⚠️ Warning: Failed to install \$pkg.\"
            fi
        fi
    "
}

_enter_container() {
    echo "✅ Environment ready. Entering container..."
    distrobox enter "$CONTAINER_NAME" -- /usr/bin/bash -i
}

# ==============================================================================
# Main
# ==============================================================================
main() {
    _validate_and_set_architecture
    _install_host_dependencies
    _apply_podman_rootless_fix
    _setup_container_home
    _ensure_container
    _configure_container_internals
    _enter_container
}

main
