---
name: workspace-macros
description: Add or change workspace shell macros under scripts/bash_macros/. Use when creating a new macro, a scripts/bash_macros bundle in a subrepo, or explaining load_macros and diag.
---

# Workspace macros

Macros are bash functions sourced in place. `load_macros` (run at shell start) discovers bundles and sources `launch/macros.bash`. Nothing is copied to `build_ws/`.

## Bundle layout

```text
<repo>/scripts/bash_macros/
  README.md
  launch/macros.bash     # @macros registry + source src/*.bash
  src/                   # implementations
    my_macro.bash
  include/               # optional private helpers
    my_macro_helpers.bash
```

`<repo>` is the directory immediately above `scripts/` (root workspace or `src/<repo>/`).

Root workspace only: `scripts/bash_macros/src/load_macros.bash` is the bootstrap. Do not add `load_macros.bash` to a subrepo. List `load_macros` in the root `launch/macros.bash` registry only.

## Rules

- Public function names must be unique across all bundles. `load_macros` aborts on collisions.
- Names starting with `_` or containing `::` are not public macros.
- Put user-facing descriptions in `launch/macros.bash` (`# macro name` plus comment lines). `diag` prints those, grouped by repo, with wrapped text.

## Helpers (larger macros)

1. Short `_foo` helpers in `include/<api>_helpers.bash`
2. Root: bind them in `include/helpers_list.bash` as `ns::_foo`
3. In `src/*.bash`, call `ns::_…`

TAB completion hides `*::*` and `_foo`.

## After adding a file

Run `load_macros` or open a new `./scripts/setup.bash` shell, then `diag` to confirm the list.

Details: [scripts/bash_macros/README.md](../../../scripts/bash_macros/README.md)
