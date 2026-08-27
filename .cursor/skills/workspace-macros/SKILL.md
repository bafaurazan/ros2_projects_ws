---
name: workspace-macros
description: Add or change workspace shell macros under scripts/bash_macros/. Use when creating a new macro, a scripts/bash_macros bundle in a subrepo, or explaining load_macros and diag.
---

# Workspace macros

Macros are bash functions sourced in place. `load_macros` (run at shell start) discovers bundles and `source`s public APIs. Nothing is copied to `build_ws/`.

## Bundle layout

```text
<repo>/scripts/bash_macros/
  README.md
  src/                       # public API (sourced)
    my_macro.bash
  include/                   # optional private helpers
    my_macro_helpers.bash
    helpers_list.bash
```

Small repos may use a flat `scripts/bash_macros/*.bash` instead of `src/`.

`<repo>` is the directory immediately above `scripts/` (root workspace or `src/<repo>/`).

Root workspace only: `scripts/bash_macros/launch/load_macros.bash` is the bootstrap. Do not add `load_macros.bash` to a subrepo.

## Rules

- Public function names must be unique across all bundles. `load_macros` aborts on collisions.
- Names starting with `_` or containing `::` are not public macros.
- Put a one-line description comment above each public function (and a `# Usage:` line). `diag` prints name, source path, and that description.

## Helpers (larger macros)

1. Short `_foo` helpers in `include/<api>_helpers.bash`
2. Bind them in `include/helpers_list.bash` as `ns::_foo`
3. In `src/*.bash`, source `include/helpers_list.bash` and call `ns::_…`

## After adding a file

Run `load_macros` or open a new `./scripts/setup.bash` shell, then `diag` to confirm the list.

Details: [scripts/bash_macros/README.md](../../../scripts/bash_macros/README.md)
