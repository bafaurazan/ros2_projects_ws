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

## Core macros

Available after setup. Names must be unique across all `scripts/bash_macros/` bundles.

- `build [colcon args...]` — rosdep / apt / pip, then `cbuild`. Requires `./src` in CWD.
- `cbuild [colcon args...]` — colcon into `./build_ws/build_<ROS_DISTRO>/`, `install_*`, `log_*`.
- `diag` — env checks and a live list of public macros (grouped by repo).
- `load_macros` — rediscover `scripts/bash_macros/` and source `launch/macros.bash` in place (no copy).
- `importer <name>` — clone a target from [`scripts/bash_macros/config/importer.repos`](scripts/bash_macros/config/importer.repos) on first use, then `load_macros`. No-op if already present. Tries `github.com`, then SSH aliases for `github.com` from `~/.ssh/config`.
- `git_ws <path> [path ...]` — recursively discover nested git repos under paths, fetch, report `ok`/`pull`/`push`/`manual`, optional shared `y/N` for safe pull/push.

Convention and layout: [scripts/bash_macros/README.md](scripts/bash_macros/README.md).

## Configured subproject extensions

Targets registered in `importer.repos`. Details and usage live in each subproject; this section is the agent map only.

### transporter

After `importer transporter`:

- `tr_pub [-y|--yes] [-clear] [path ...]` / `tr_sub [-y|--yes] [-clear]` — copy into `inbox/` as regular files (optional paths; nested `.git` / `.gitignore` stripped), commit, then pull+push; `tr_sub` is fetch+pull and fails if dirty. `-clear` resets history; `-y` skips prompts.

Docs: [src/transporter/README.md](src/transporter/README.md), [src/transporter/scripts/bash_macros/README.md](src/transporter/scripts/bash_macros/README.md).

### notaura_ws

After `importer notaura_ws`:

- `notaura_ws_import_repos [docs|code|vendor|all|status]` — clone/update nested repos (same GitHub SSH Host list as `importer`).
- `latex [path-to.tex|dir]` — after `notaura_ws_import_repos docs` (and `load_macros`); builds under `src/notaura_ws/docs/` (default: thesis `main.tex`) via Docker `texlive/texlive` or host `latexmk` / `pdflatex`.

Docs: [src/notaura_ws/README.md](src/notaura_ws/README.md), [src/notaura_ws/scripts/bash_macros/README.md](src/notaura_ws/scripts/bash_macros/README.md). Nested thesis macros: [src/notaura_ws/docs/notaura_thesis/README.md](src/notaura_ws/docs/notaura_thesis/README.md).

## Layout

- `scripts/` — `bash_bringup`, `bash_env`, `bash_macros` (CLI: `setup.bash`)
- `src/` — cloned subprojects (each may have its own `scripts/bash_macros/`, `.cursor/`, `AGENTS.md`)
- `./build_ws/` — colcon artifacts in the project you build; not a macro cache
- `.cursor/` — workspace rules and skills (git); subrepos may add their own. Style: `.cursor/rules/cpp/`, `python/naming.mdc`, `bash/naming.mdc`. ROS 2 entry/build (`build`/`cbuild`, Distrobox, `bash_macros/`): [`.cursor/rules/ros2/workspace.mdc`](.cursor/rules/ros2/workspace.mdc). Bundle namespace: [`bash/macros.mdc`](.cursor/rules/bash/macros.mdc).

Do not edit `.distrobox_*` homes. Nested `AGENTS.md` / `.cursor/` under `src/<repo>/` apply when working in that subtree.
