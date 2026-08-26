# Workspace macros

Each repository keeps helpers in `scripts/macros/` (`*.bash` plus this README). The shell (`./scripts/setup.bash humble|jazzy|macros`) copies those folders into a single cache and sources them from there.

## Convention for new repositories

Put macros here:

```text
<repo>/scripts/macros/
  helper.bash
  README.md
```

`<repo>` is the directory immediately above `scripts/` (works for `src/<repo>/scripts/macros/` and nested vendor trees such as `src/notaura_ws/src/vendor/foo/scripts/macros/`).

After the next `sync_macros` (or a new shell), the bundle appears at:

```text
$ROS2_PROJECTS_WS_ROOT/build_ws/macros/<repo>/
```

Function names must be unique across all repos. `sync_macros` aborts on collisions.

## Core macros (this folder)

- `build [colcon args...]` — install rosdep / apt / pip dependencies, then run `cbuild`. Operates on `./src` in the current directory.
- `cbuild [colcon args...]` — `colcon build` into `./build_ws/build_<ROS_DISTRO>/`, `install_<ROS_DISTRO>/`, `log_<ROS_DISTRO>/`, then source the install overlay.
- `diag` — environment checks plus **Available macros** (from `macros_index`).
- `sync_macros` — rediscover `scripts/macros/` under the workspace root, recopy into `$ROS2_PROJECTS_WS_ROOT/build_ws/macros/`, validate names, rewrite `macros_index`, source copies.

`sync.bash` is copied into the cache like any other macro file; the shell sources it from `build_ws/macros/<workspace>/sync.bash`.

## Two `build_ws` directories

| Location | Role |
|---|---|
| `$ROS2_PROJECTS_WS_ROOT/build_ws/macros/` | Global macro cache (independent of current directory) |
| `./build_ws/` in the project you build | Colcon artifacts only (`build_*`, `install_*`, `log_*`) |

`rm -rf ./build_ws` in a project deletes that project's colcon output. Macros stay in the workspace-root cache. `rm -rf $ROS2_PROJECTS_WS_ROOT/build_ws` drops the cache; the next shell (or `sync_macros`) recreates it.
