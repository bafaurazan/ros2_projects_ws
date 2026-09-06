# Workspace macros

Each repository keeps a `scripts/bash_macros/` bundle. The shell (`./scripts/setup.bash humble|jazzy|macros`) discovers those folders and sources public APIs **in place** (no copy, no cache).

## Bundle layout

```text
<repo>/scripts/bash_macros/
  README.md
  launch/macros.bash     # @macros registry (for diag) + source src/*.bash
  src/                   # function implementations
    my_macro.bash
  include/               # optional namespaced helpers (ns::_foo)
  config/                # optional data (e.g. importer.repos)
```

`<repo>` is the directory immediately above `scripts/` (root workspace or `src/<repo>/`).

Function names must be unique across all repos. `load_macros` aborts on collisions of **public** macros. Names starting with `_` or containing `::` are not public macros. Prefix and namespace conventions: [`.cursor/rules/bash/naming.mdc`](../../.cursor/rules/bash/naming.mdc), [`.cursor/rules/bash/macros.mdc`](../../.cursor/rules/bash/macros.mdc).

The same helper names and TAB completion must work on Windows/Git Bash and native Linux.

### `launch/macros.bash` registry

User-facing descriptions live only in the `@macros-begin` … `@macros-end` block. `diag` groups macros by repo and wraps those descriptions.

```bash
# @macros-begin
# macro my_macro
#   One or more comment lines of description.
# @macros-end
```

Do not copy root `src/load_macros.bash` into a subrepo. Root `launch/macros.bash` lists `load_macros` in the registry; subrepos do not.

### Helpers (optional)

Define helpers as real `ns::_foo` bodies in `include/<api>_helpers.bash`. Call `ns::_foo` from `src/*.bash` and from other helpers. Do not leave a short global `_foo`.

Bash has no private functions. `ns::_foo` is still global; the name is unique per bundle (`tr::_get_dir` vs `latex::_get_dir`) and is not a public macro.

### TAB completion

After `load_macros`, public macros get a compspec. First-word TAB prefers those names when the prefix matches (`dia` → `diag`, not `diag::*`; `tr_` → `tr_pub` / `tr_sub`, not `tr.exe`). Other first-word completion stays command-like (Windows binaries with `.exe` / `.dll` are dropped).

## Core macros (this folder)

- `build [colcon args...]` — rosdep / apt / pip, then `cbuild`. Requires ROS 2 toolchain (Distrobox on native Linux).
- `cbuild [colcon args...]` — rediscovers macros (`load_macros`), then `colcon build` into `./build_ws/`, then source the install overlay (skipped if colcon fails).
- `diag` — environment checks and the public macro list (from launch registries).
- `load_macros` — rediscover `scripts/bash_macros/` bundles and re-source `launch/macros.bash`.
- `importer <name>` — clone a target from `config/importer.repos` on first use; ignores the command if already present. Tries `github.com`, then any `Host` aliases in `~/.ssh/config` whose `HostName` is `github.com` (falls back to `github.com` if that file is missing).
- `notaura_ws_import_repos` (after `importer notaura_ws`) uses that same host list when cloning from `.repos` files.

Entry: `scripts/bash_macros/launch/macros.bash` (used by `bash_bringup/src/macros_session.bash` and `bash_container/src/container_session.bash`).

## `build_ws`

`./build_ws/` in the project you build holds colcon artifacts only (`build_*`, `install_*`, `log_*`). Macros are not stored there.
