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
# macro git_ws
#   Discover git repos under given paths recursively (skips
#   build/build_ws/install/log/trash). Always also checks the
#   ros2_projects_ws repo (ROS2_PROJECTS_WS_ROOT). git fetch --prune,
#   diag-style report per repo (branch, vs origin/develop, upstream,
#   remotes, local without remote), tags ok/develop/behind-develop/pull/push/push-upstream/
#   switch/manual (fetch news appends " - info" to the tag). Separate y/N per safe action (pull: y/i/N; i = incoming
#   diff); orphan locals get p/d/N always (d asks Are you sure? before
#   local delete). No flags; develop only (not main); no branch -u.
#   Paths required.
#   Usage: git_ws <path> [path ...]
# @macros-end

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bundle_load.bash"
