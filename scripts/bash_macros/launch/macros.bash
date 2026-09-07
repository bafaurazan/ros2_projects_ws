#!/usr/bin/bash
#
# @macros-begin
# macro build
#   Install workspace dependencies (rosdep, apt_packages.txt,
#   requirements.txt), then run cbuild.
# macro cbuild
#   Distro-aware colcon build into ./build_ws/build_<ROS_DISTRO>/,
#   then source the install overlay.
# macro diag
#   Print system/tools/env info, verify env setup, and list macros.
# macro load_macros
#   Rediscover scripts/bash_macros/ bundles and re-source launch/macros.bash.
# macro importer
#   Clone a registered subrepo on first use; ignores the command if
#   already present. Targets live in scripts/bash_macros/config/importer.repos.
#   Tries github.com then SSH aliases for github.com from ~/.ssh/config.
#   Usage: importer <name>
# @macros-end

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bundle_load.bash"
