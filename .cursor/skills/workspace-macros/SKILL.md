---
name: workspace-macros
description: Add or change workspace shell macros under scripts/macros/. Use when creating a new macro, a scripts/macros bundle in a subrepo, or explaining sync_macros and diag.
---

# Workspace macros

Macros are bash functions sourced in place. `sync_macros` (run at shell start) discovers bundles and `source`s public APIs. Nothing is copied to `build_ws/`.

## Bundle layout

```text
<repo>/scripts/macros/
  README.md
  api/                       # public API (sourced)
    my_macro.bash
  helpers/                   # optional private helpers
    my_macro_helpers.bash
    helpers_list.bash
```

Small repos may use a flat `scripts/macros/*.bash` instead of `api/`.

`<repo>` is the directory immediately above `scripts/` (root workspace or `src/<repo>/`).

## Rules

- Public function names must be unique across all bundles. `sync_macros` aborts on collisions.
- Names starting with `_` or containing `::` are not public macros.
- Put a one-line description comment above each public function (and a `# Usage:` line). `diag` prints name, source path, and that description.

## Helpers (larger macros)

1. Short `_foo` helpers in `helpers/<api>_helpers.bash`
2. Bind them in `helpers/helpers_list.bash` as `ns::_foo`
3. In `api/*.bash`, source `helpers/helpers_list.bash` and call `ns::_…`

## After adding a file

Run `sync_macros` or open a new `./scripts/setup.bash` shell, then `diag` to confirm the list.

Details: [scripts/macros/README.md](scripts/macros/README.md)
