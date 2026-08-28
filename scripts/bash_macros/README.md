# Workspace macros

Each repository keeps a `scripts/bash_macros/` bundle. The shell (`./scripts/setup.bash humble|jazzy|macros`) discovers those folders and sources public APIs **in place** (no copy, no cache).

## Bundle layout

```text
<repo>/scripts/bash_macros/
  README.md
  launch/macros.bash     # @macros registry (for diag) + source src/*.bash
  src/                   # function implementations
    my_macro.bash
  include/               # optional private helpers (_foo, ns::_foo)
```

`<repo>` is the directory immediately above `scripts/` (root workspace or `src/<repo>/`).

Function names must be unique across all repos. `load_macros` aborts on collisions. Names starting with `_` or containing `::` are not public macros.

### `launch/macros.bash` registry

User-facing descriptions live only in the `@macros-begin` … `@macros-end` block. `diag` groups macros by repo and wraps those descriptions.

```bash
# @macros-begin
# macro my_macro
#   One or more comment lines of description.
# @macros-end
```

Do not copy root `src/load_macros.bash` into a subrepo. Root `launch/macros.bash` lists `load_macros` in the registry; subrepos do not.

### Helpers + namespace (optional)

1. Short `_foo` helpers in `include/<api>_helpers.bash`
2. Root bundle: register them in `include/helpers_list.bash` as `ns::_foo`
3. In `src/*.bash`, call `ns::_…` from the public function

TAB completion hides `*::*` and `_foo`; the functions stay in the shell.

## Core macros (this folder)

- `build [colcon args...]` — rosdep / apt / pip, then `cbuild`. Requires ROS 2 toolchain (Distrobox on native Linux).
- `cbuild [colcon args...]` — `colcon build` into `./build_ws/`, then source the install overlay (skipped if colcon fails).
- `diag` — environment checks and the public macro list (from launch registries).
- `load_macros` — rediscover `scripts/bash_macros/` bundles and re-source `launch/macros.bash`.

Entry: `scripts/bash_macros/launch/macros.bash` (used by `bash_bringup/src/macros_session.bash` and `bash_container/src/container_session.bash`).

## `build_ws`

`./build_ws/` in the project you build holds colcon artifacts only (`build_*`, `install_*`, `log_*`). Macros are not stored there.
