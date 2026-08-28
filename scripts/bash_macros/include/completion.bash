#!/usr/bin/bash

# Hide namespaced helpers (diag:: / build:: / load::) and _* from TAB completion
# for the first word on the line only. Does not override git or other subcommand
# completion (no complete -D). Sourced after load_macros.

_macros_completion_filter() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cand
    COMPREPLY=()
    while IFS= read -r cand; do
        [[ -n "$cand" ]] || continue
        [[ "$cand" == *::* ]] && continue
        [[ "$cand" == _* ]] && continue
        COMPREPLY+=("$cand")
    done < <(compgen -A function -- "$cur")
    while IFS= read -r cand; do
        [[ -n "$cand" ]] || continue
        COMPREPLY+=("$cand")
    done < <(compgen -c -- "$cur")
}

_macros_install_completion_filter() {
    complete -I -F _macros_completion_filter 2>/dev/null || true
}
