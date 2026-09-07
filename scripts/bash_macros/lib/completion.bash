#!/usr/bin/bash

# TAB completion for public macros (Linux + Windows/Git Bash).
# Does not use complete -I as the only path (unreliable on some Git Bash
# builds). When complete -I works, first-word TAB prefers public macros
# if the prefix matches (dia → diag, not diag::*; tr_ → tr_pub, not tr.exe).

_MACROS_COMPLETION_NAMES=()

_macros_list_public() {
    local line name
    while IFS= read -r line; do
        name="${line##* }"
        [[ -n "$name" ]] || continue
        [[ "$name" == _* ]] && continue
        [[ "$name" == *::* ]] && continue
        printf '%s\n' "$name"
    done < <(declare -F)
}

_macros_complete_public() {
    COMPREPLY=()
}

_macros_complete_first_word() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cand matched_macro=0
    COMPREPLY=()

    while IFS= read -r cand; do
        [[ -n "$cand" ]] || continue
        if [[ "$cand" == "$cur"* ]]; then
            COMPREPLY+=("$cand")
            matched_macro=1
        fi
    done < <(_macros_list_public)

    if [[ "$matched_macro" -eq 1 ]]; then
        return 0
    fi

    while IFS= read -r cand; do
        [[ -n "$cand" ]] || continue
        [[ "$cand" == _* ]] && continue
        [[ "$cand" == *::* ]] && continue
        case "$cand" in
            *.exe|*.EXE|*.dll|*.DLL|*.com|*.COM) continue ;;
        esac
        COMPREPLY+=("$cand")
    done < <(compgen -A function -- "$cur"; compgen -c -- "$cur")
}

_install_macros_completion() {
    local name
    for name in "${_MACROS_COMPLETION_NAMES[@]+"${_MACROS_COMPLETION_NAMES[@]}"}"; do
        complete -r "$name" 2>/dev/null || true
    done
    _MACROS_COMPLETION_NAMES=()

    while IFS= read -r name; do
        [[ -n "$name" ]] || continue
        _MACROS_COMPLETION_NAMES+=("$name")
        complete -o default -F _macros_complete_public "$name"
    done < <(_macros_list_public)

    complete -I -F _macros_complete_first_word 2>/dev/null || true
}

# Back-compat name used by older session scripts until they reload.
_install_completion_filter() {
    _install_macros_completion
}
