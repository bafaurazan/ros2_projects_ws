# Agent notes — ros2_projects_ws

Meta-workspace: Distrobox ROS 2 environment plus shared shell macros. Open this folder as the Cursor workspace.

## Entry

From the workspace root:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
```

`humble` / `jazzy` enter Distrobox (`ros2_projects_ws_<distro>`) on **native Linux**. `macros` loads shell macros only (Git Bash / host; no ROS). Distrobox is not supported on Windows or WSL.

Script layout: [scripts/README.md](scripts/README.md).

## Macros

Available after setup. Names must be unique across all `scripts/bash_macros/` bundles.

- `build [colcon args...]` — rosdep / apt / pip, then `cbuild`. Requires `./src` in CWD.
- `cbuild [colcon args...]` — colcon into `./build_ws/build_<ROS_DISTRO>/`, `install_*`, `log_*`.
- `diag` — env checks and a live list of public macros (grouped by repo).
- `load_macros` — rediscover `scripts/bash_macros/` and source `launch/macros.bash` in place (no copy).
- `importer transporter|notaura_ws` — clone that repo under `src/` (branch `develop`) on first use, then `load_macros`. No-op if already present. Tries `github.com`, then SSH aliases for `github.com` from `~/.ssh/config`.
- `tr_pub [-y|--yes] [-clear] [path ...]` / `tr_sub [-y|--yes] [-clear]` — after `importer transporter`: `tr_pub` copies into `inbox/` (optional, one or more paths), commits local changes, then pull+push commits ahead of the remote. `tr_sub` is fetch+pull and fails if the tree is dirty. `-clear` resets history (`tr_pub`: squash + force-push; `tr_sub`: `reset --hard` to remote). `-y` skips collision and `-clear` prompts.
- `notaura_ws_import_repos [docs|code|vendor|all|status]` — after `importer notaura_ws`. Tries the same GitHub SSH Host list as `importer`.

Convention and layout: [scripts/bash_macros/README.md](scripts/bash_macros/README.md).

## Layout

- `scripts/` — `bash_bringup`, `bash_container`, `bash_macros` (CLI: `setup.bash`)
- `src/` — cloned subprojects (each may have its own `scripts/bash_macros/`, `.cursor/`, `AGENTS.md`)
- `./build_ws/` — colcon artifacts in the project you build; not a macro cache
- `.cursor/` — workspace rules and skills (git); subrepos may add their own. Style: `.cursor/rules/cpp/`, `python/naming.mdc`, `bash/naming.mdc`. ROS 2 entry/build (`build`/`cbuild`, Distrobox, `bash_macros/`): [`.cursor/rules/ros2-workspace.mdc`](.cursor/rules/ros2-workspace.mdc). Bundle namespace: [`bash/macros.mdc`](.cursor/rules/bash/macros.mdc).

Do not edit `.distrobox_*` homes. Nested `AGENTS.md` / `.cursor/` under `src/<repo>/` apply when working in that subtree.
