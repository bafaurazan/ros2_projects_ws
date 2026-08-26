#!/usr/bin/bash

# Print system/tools/env info, verify env setup settings, and list available macros
# (name, source path, description from comments).

_macros_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${_macros_dir}/helpers/helpers_list.bash"
unset _macros_dir

diag() {
    diag::_print_system
    diag::_print_tools
    diag::_print_environment

    local checks_ok=0
    if diag::_print_checks; then
        checks_ok=1
    fi

    diag::_print_macros

    if [[ "$checks_ok" -eq 1 ]]; then
        echo
        echo "Diagnostic status: OK"
        return 0
    fi

    echo
    echo "Diagnostic status: FAIL"
    return 1
}
