# ROS2 Projects Workspace

Minimal ROS 2 workspace tooling with:
- one launcher: `./scripts/distrobox <humble|jazzy>`
- one env file loaded automatically in container shells
- one build macro: `build`

## Prerequisites (host)

Install these on the **host** (outside the container):

| Dependency | Why |
|---|---|
| [Docker](https://www.docker.com) **or** [Podman](https://podman.io) | Container runtime used by Distrobox |
| [Distrobox](https://github.com/89luca89/distrobox) | Creates/enters ROS containers |
| `flatpak` | Used by Distrobox tooling; `./scripts/distrobox` installs it via apt if missing |
| `fuse-overlayfs` | Required for rootless Podman with large images; installed automatically when Podman is detected |

Example (Ubuntu/Debian host):

```bash
# Container runtime — pick one
sudo apt install docker.io
# or
sudo apt install podman

sudo apt install distrobox flatpak
# Podman only:
sudo apt install fuse-overlayfs
```

You do **not** need to install ROS, `colcon`, or `rosdep` on the host — they come from the container image.

Inside the container, `./scripts/distrobox` also ensures:
- ROS image (`osrf/ros:<distro>-desktop-full` on x86_64, `arm64v8/ros:<distro>-ros-base` on aarch64)
- `ros-<distro>-rmw-cyclonedds-cpp`
- basic tools (`git`, `python3-pip`, `vim`, USB utils, …)

## Start Container

From the workspace root:

```bash
./scripts/distrobox humble
./scripts/distrobox jazzy
```

What this does:
- creates (if needed) and enters container `ros2_projects_ws_<distro>`
- uses an isolated home under `.distrobox_<distro>/`
- appends an env hook to container `~/.bashrc` (idempotent)
- auto-loads `scripts/ros2_env.bash` in every new interactive shell inside the container

`ros2_env.bash` sets:
- `ROS_DISTRO`
- `ROS_DOMAIN_ID` (default `0`, unless already set)
- `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`
- `CYCLONEDDS_URI=file://.../scripts/cyclone-dds.xml`
- sources `/opt/ros/$ROS_DISTRO/local_setup.bash`
- sources `scripts/macros.bash` (`build`, `cbuild`, `diag`)

## Build Macro

`build` is the main helper. It always operates on the **current working directory** — that directory must contain `./src` with ROS packages.

### Usage

```bash
# Full bootstrap + build of everything under ./src
build

# Build selected packages only (exact colcon package names)
build my_pkg another_pkg

# Skip dependency installation; only run colcon
build --no-deps
build --no-deps my_pkg
```

Any arguments after an optional `--no-deps` are forwarded to `colcon build` (e.g. package names, `--packages-up-to`, `--cmake-args`, …).

### Step-by-step: what `build` does

1. **Guard** — fails if `./src` is missing in the current directory.

2. **Dependencies** (unless `--no-deps`):
   - `rosdep update --rosdistro $ROS_DISTRO`
   - `rosdep install` from `./src` (also scans nested “package clusters”: directories under `./src` that contain ≥2 sibling `package.xml` trees, so vendor layouts still resolve)
   - installs every package listed in any `apt_packages.txt` found under `./src` (`sudo apt-get install -y …`)
   - installs every `requirements.txt` found under `./src` (`python3 -m pip install -r …`)

3. **Build** — calls the distro-aware colcon wrapper (same as `cbuild`):
   - discovers packages with `--base-paths ./src`
   - uses `--symlink-install`
   - writes artifacts under `./build_ws/` (per distro, so humble and jazzy do not clash):

     | Path | Role |
     |---|---|
     | `build_ws/build_<ROS_DISTRO>/` | build trees |
     | `build_ws/install_<ROS_DISTRO>/` | install space |
     | `build_ws/log_<ROS_DISTRO>/` | colcon logs |

4. **Source** — if `build_ws/install_<ROS_DISTRO>/local_setup.bash` exists, sources it into the current shell so newly built packages are immediately usable.

### Related: `cbuild`

`cbuild` is only the colcon step (no rosdep / apt / pip). Same paths and `--symlink-install` behavior as above.

```bash
cbuild
cbuild --packages-select my_pkg
```

### Typical workflow

```bash
./scripts/distrobox jazzy
cd path/to/your_ws          # directory that contains ./src
build                       # deps + build + source install
# or later, after deps are already installed:
build --no-deps my_pkg
```

## Diagnostic Macro

```bash
diag
```

Prints system/tool info and checks that `ros2_env.bash` loaded correctly (RMW, CycloneDDS URI, env marker, working `cmake`).

## Project Structure

```text
scripts/
  distrobox          # host launcher → create/enter container
  ros2_env.bash      # auto-sourced in container shells
  macros.bash        # build, cbuild, diag
  cyclone-dds.xml
src/                 # put / link ROS workspaces here
build_ws/            # created by build (gitignored artifacts)
```

## GUI over SSH (window on the Pi’s screen)

SSH does not set `DISPLAY` by default. `ros2_env.bash` can pick a local X11 socket (`:0` / `:1`) and a non-empty `XAUTHORITY` so GUI tools (RViz, Qt) open on the machine’s monitor. Prefer the **same Linux user** as the graphical login.

Disable auto-selection: `export ROS2_AUTO_LOCAL_DISPLAY=0`.

If you see **“Authorization required, but no authorization protocol specified”**, set `XAUTHORITY` from the local desktop session (`echo $XAUTHORITY`), or on the desktop:

```bash
xhost +SI:localuser:$(whoami)
```
