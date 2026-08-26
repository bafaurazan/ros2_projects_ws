# Workspace macros

Each repository keeps a `scripts/macros/` bundle (`api/`, optional `helpers/`, plus this README). The shell (`./scripts/setup.bash humble|jazzy|macros`) copies those folders into a single cache and sources the public API from there.

## Convention for new repositories

```text
<repo>/scripts/macros/
  README.md
  api/                       # public API (sourced by sync_macros)
    my_macro.bash
  helpers/                   # optional private helpers + namespace list
    my_macro_helpers.bash    # short _* implementations
    helpers_list.bash        # bind short names → ns::_*
```

Small repos may keep a flat layout (`scripts/macros/*.bash` only); `sync_macros` still supports that for compatibility.

`<repo>` is the directory immediately above `scripts/` (works for `src/<repo>/scripts/macros/` and nested vendor trees such as `src/notaura_ws/src/vendor/foo/scripts/macros/`).

After the next `sync_macros` (or a new shell), the bundle appears at:

```text
$ROS2_PROJECTS_WS_ROOT/build_ws/macros/<repo>/
```

Function names must be unique across all repos. `sync_macros` aborts on collisions. Names starting with `_` or containing `::` are not public macros.

### Helpers + namespace (optional, recommended for larger macros)

1. Implement private helpers with short names in `helpers/<api>_helpers.bash` (e.g. `_print_system`).
2. Register them in `helpers/helpers_list.bash` so they become `diag::_print_system`, `build::_has_src_dir`, …
3. In `api/*.bash`, `source` `helpers/helpers_list.bash` (via macros root) and call `ns::_…` from the public function.

`sync_macros` copies the whole tree (`api/` + `helpers/`) but only sources `api/*.bash` (or top-level `*.bash` for flat bundles).

## Core macros (this folder)

- `build [colcon args...]` — install rosdep / apt / pip dependencies, then run `cbuild`. Operates on `./src` in the current directory.
- `cbuild [colcon args...]` — `colcon build` into `./build_ws/build_<ROS_DISTRO>/`, `install_<ROS_DISTRO>/`, `log_<ROS_DISTRO>/`, then source the install overlay.
- `diag` — environment checks plus **Available macros** (from `macros_index`).
- `sync_macros` — rediscover `scripts/macros/` under the workspace root, recopy into `$ROS2_PROJECTS_WS_ROOT/build_ws/macros/`, validate names, rewrite `macros_index`, source copies.

Entry: `scripts/macros/api/sync.bash` (also the bootstrap used by Distrobox / `macros` mode).

## Two `build_ws` directories

| Location | Role |
|---|---|
| `$ROS2_PROJECTS_WS_ROOT/build_ws/macros/` | Global macro cache (independent of current directory) |
| `./build_ws/` in the project you build | Colcon artifacts only (`build_*`, `install_*`, `log_*`) |

`rm -rf ./build_ws` in a project deletes that project's colcon output. Macros stay in the workspace-root cache. `rm -rf $ROS2_PROJECTS_WS_ROOT/build_ws` drops the cache; the next shell (or `sync_macros`) recreates it.
