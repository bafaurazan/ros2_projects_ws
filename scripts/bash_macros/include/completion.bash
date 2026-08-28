#!/usr/bin/bash

# Hide namespaced helpers (diag:: / build:: / load::) and _* from TAB completion.
# Sourced after load_macros. Does not unset the functions.

_macros_completion_filter() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cand
    COMPREPLY=()
    while IFS= read -r cand; do
        [[ -n "$cand" ]] || continue
        [[ "$cand" == *::* ]] && continue
        [[ "$cand" == _* ]] && continue
        COMPREPLY+=("$cand")
    done < <(compgen -c -- "$cur")
}

_macros_install_completion_filter() {
    complete -I -F _macros_completion_filter 2>/dev/null || true
    complete -D -F _macros_completion_filter 2>/dev/null || true
}
