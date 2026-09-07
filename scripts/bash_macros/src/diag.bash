#!/usr/bin/bash

# Usage: diag

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
