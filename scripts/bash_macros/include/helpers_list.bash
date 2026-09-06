#!/usr/bin/bash

# Source namespaced helper bodies (diag:: / build:: / load:: / importer::).

_helpers_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_helpers_dir}/diag_helpers.bash"
# shellcheck disable=SC1091
source "${_helpers_dir}/build_helpers.bash"
# shellcheck disable=SC1091
source "${_helpers_dir}/load_helpers.bash"
# shellcheck disable=SC1091
source "${_helpers_dir}/importer_helpers.bash"
unset _helpers_dir
