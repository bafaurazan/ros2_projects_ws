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
#   Clone a registered subrepo (develop) on first use; no-op if
#   already present. Usage: importer transporter|notaura_ws
# @macros-end

_bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${_bundle_dir}/include/helpers_list.bash" ]]; then
    # shellcheck disable=SC1091
    source "${_bundle_dir}/include/helpers_list.bash"
fi

_src_file=
shopt -s nullglob
for _src_file in "${_bundle_dir}/src"/*.bash; do
    # shellcheck disable=SC1090
    source "$_src_file"
done
shopt -u nullglob
unset _src_file _bundle_dir
