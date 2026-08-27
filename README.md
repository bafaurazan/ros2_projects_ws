# ROS2 Projects Workspace

Ready-to-use ROS 2 environment in a Distrobox container, plus a shared macro system (`build`, `cbuild`, `diag`, …) — including macros from repositories under `src/`.

- **Entry point:** `./scripts/setup.bash <humble|jazzy [prod]|macros>`
- **Scripts layout:** [scripts/README.md](scripts/README.md)
- **Macros:** [scripts/bash_macros/README.md](scripts/bash_macros/README.md)
- **Agent:** [AGENTS.md](AGENTS.md); Cursor rules/skills in `.cursor/` (subprojects may add their own)

## Host requirements

Tested with **Podman** and **Distrobox** (curl install):

```bash
sudo apt install podman
curl -fsSL https://raw.githubusercontent.com/89luca89/distrobox/legacy/install | sh
```

You do not need ROS, `colcon`, or `rosdep` on the host — they come from the container.

## Start

From the workspace root:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
```

`humble` / `jazzy` create (if needed) and enter container `ros2_projects_ws_<distro>`:

- picks a ROS image (`desktop-full` on x86_64, `ros-base` on arm)
- installs CycloneDDS RMW, git, pip, USB tools, and related packages in the container
- uses an isolated home under `.distrobox_<distro>/`
- hooks `~/.bashrc` to auto-load `scripts/bash_container/src/container_session.bash` (ROS, middleware, macros)

`macros` opens an interactive bash with workspace macros only (no Distrobox / no ROS). Use this on Git Bash for helpers such as `notaura_thesis_build`. `exit` returns to the previous shell.

Optional: `source scripts/setup.bash macros` loads macros in the current shell instead of opening a new one.

### TODO: production runtime (`prod`)

CLI is reserved:

```bash
./scripts/setup.bash jazzy prod
./scripts/setup.bash humble prod
```

Not implemented yet. Intended for an isolated production image (instead of Distrobox). Runtime engine (Docker or Podman) will be chosen at implementation time — the flag stays `prod`, not `docker` / `podman`. Stub: `scripts/bash_container/src/docker/`.

## Work inside the container

1. `./scripts/setup.bash jazzy`
2. `cd` to a directory that contains `./src`
3. `build` — dependencies + colcon, or `cbuild` — colcon only

### build

Installs dependencies (rosdep, apt, pip) and builds the workspace.

```bash
build
build --packages-select my_pkg
```

### cbuild

Colcon only (no dependency install). Extra arguments are passed to `colcon build`.

```bash
cbuild
cbuild --packages-select my_pkg
```

Implementation details: [scripts/bash_macros/README.md](scripts/bash_macros/README.md).

### `build_ws`

`./build_ws/` in the directory you build holds colcon artifacts (`build_*`, `install_*`, `log_*`). `rm -rf ./build_ws` deletes that project's colcon output. Macros are sourced from `scripts/bash_macros/` in place; `diag` lists them.

## Macros

Convention: each repo keeps `scripts/bash_macros/` (`src/*.bash`, optional `include/`, `README.md`). After the shell starts, `load_macros` sources those public APIs from their original paths.

Full documentation, the convention for new repos, and `build` / `cbuild` / `diag` / `load_macros` → [scripts/bash_macros/README.md](scripts/bash_macros/README.md)

`notaura_thesis_build` and other host-side helpers work with `./scripts/setup.bash macros`. ROS `build` / `cbuild` still need Distrobox. Requires `latexmk` or `pdflatex` on the host (MiKTeX / TeX Live) for the thesis.

## Project structure

```text
AGENTS.md               # agent map (git)
.cursor/                # workspace rules + skills (git)
scripts/
  setup.bash            # ./scripts/setup.bash humble|jazzy [prod]|macros
  README.md
  bash_bringup/         # CLI router + host macros session
  bash_container/       # Distrobox/Docker runtime + in-container session
  bash_macros/          # launch/load_macros.bash, src/, include/
src/                    # subprojects (each may have scripts/bash_macros/, .cursor/, AGENTS.md)
build_ws/               # per-project colcon artifacts (created in CWD by build/cbuild)
```
