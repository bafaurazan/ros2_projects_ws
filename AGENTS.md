# Agent notes — ros2_projects_ws

Meta-workspace: Distrobox ROS 2 environment plus shared shell macros. Open this folder as the Cursor workspace.

## Entry

From the workspace root:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
```

`humble` / `jazzy` enter Distrobox (`ros2_projects_ws_<distro>`). `macros` loads shell macros only (Git Bash / host; no ROS).

Script layout: [scripts/README.md](scripts/README.md).

## Macros

Available after setup. Names must be unique across all `scripts/bash_macros/` bundles.

- `build [colcon args...]` — rosdep / apt / pip, then `cbuild`. Requires `./src` in CWD.
- `cbuild [colcon args...]` — colcon into `./build_ws/build_<ROS_DISTRO>/`, `install_*`, `log_*`.
- `diag` — env checks and a live list of macros (name, source path, description).
- `load_macros` — rediscover `scripts/bash_macros/` and source public APIs in place (no copy).

Convention and layout: [scripts/bash_macros/README.md](scripts/bash_macros/README.md).

## Layout

- `scripts/` — `bash_bringup`, `bash_container`, `bash_macros` (CLI: `setup.bash`)
- `src/` — cloned subprojects (each may have its own `scripts/bash_macros/`, `.cursor/`, `AGENTS.md`)
- `./build_ws/` — colcon artifacts in the project you build; not a macro cache
- `.cursor/` — workspace rules and skills (git); subrepos may add their own

Do not edit `.distrobox_*` homes. Nested `AGENTS.md` / `.cursor/` under `src/<repo>/` apply when working in that subtree.
