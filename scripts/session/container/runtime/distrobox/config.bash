#!/usr/bin/bash

# Distrobox backend constants. Sourced by setup.bash.

ROS_DISTRO="${1:-${ROS_DISTRO:-humble}}"

_distrobox_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS_DIR="$(cd "${_distrobox_dir}/../../../../.." && pwd)"

CONTAINER_NAME="ros2_projects_ws_${ROS_DISTRO}"
DISTROBOX_HOME="${WS_DIR}/.distrobox_${ROS_DISTRO}"
CONTAINER_SESSION_SETUP="/run/host${WS_DIR}/scripts/session/container/setup.bash"

ROS_IMAGE=""
ADDITIONAL_PACKAGES="iputils-ping nano vim alsa-utils alsa pulseaudio git git-man python3 python-is-python3 python3-pip usbutils"
