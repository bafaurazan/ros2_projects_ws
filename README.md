# ROS2 Projects Workspace

Minimal ROS 2 workspace tooling with:
- one launcher: `./scripts/distrobox <humble|jazzy>`
- one env file loaded automatically in container shells
- one build macro: `build`

## Prerequisites

- [Docker](https://www.docker.com) or [Podman](https://podman.io)
- [Distrobox](https://github.com/89luca89/distrobox)
- `rosdep`, `colcon`, `python3-pip` available in container image

## Git submodules

If this repository uses **git submodules** (for example under `src/`), initialize them after clone or submodule directories will stay empty.

**Fresh clone (fetch submodules in one step):**

```bash
git clone --recurse-submodules <repository-url>
```

**Already cloned without submodules:**

```bash
cd ros2_projects_ws
git submodule update --init --recursive
```

**Update after `git pull`:**

```bash
git pull --recurse-submodules
# or if submodule pointers moved:
git submodule update --init --recursive
```

Optional: make a plain `git pull` recurse into submodules:

```bash
git config --global submodule.recurse true
```

## Start Container

Run one of:

```bash
./scripts/distrobox humble
./scripts/distrobox jazzy
```

What this does:
- creates/enters distro-specific container (`ros2_projects_ws_<distro>`)
- appends env hook to container `~/.bashrc` (idempotent)
- auto-loads `scripts/ros2_env.bash` in every new terminal inside container

`ros2_env.bash` sets:
- `ROS_DISTRO`
- `ROS_DOMAIN_ID` (default `0`, unless already set)
- `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`
- `CYCLONEDDS_URI=file://.../scripts/cyclone-dds.xml`
- source `/opt/ros/$ROS_DISTRO/local_setup.bash`
- source `scripts/macros.bash` (contains `build`)
- if `DISPLAY` is empty and a local X11 socket exists (`/tmp/.X11-unix/X0` or `X1`), sets `DISPLAY` and searches for a non-empty **`XAUTHORITY`** file so GUI tools over **SSH** can show on the **Pi’s monitor** (see below)

## GUI over SSH (window on the Pi’s screen)

SSH does not set `DISPLAY` by default, so Qt/RViz would try to open no display. `ros2_env.bash` picks a local X11 socket (`:0` / `:1`) and tries common **`XAUTHORITY`** locations (e.g. `~/.Xauthority`, GDM/LightDM paths under `/run/user/…`, Mutter XWayland cookies) so clients authenticate correctly. Use the **same Linux user** as the graphical login when possible.

```bash
ros2 launch teleop_bringup g1_arm_control.launch.py use_gui:=true
```

If you see **“Authorization required, but no authorization protocol specified”**, the cookie file was not found automatically. On the Pi’s **local desktop** terminal (logged-in session), run `echo $XAUTHORITY` and copy that path into your SSH session: `export XAUTHORITY=/that/path`. Alternatively relax local access (less secure):

```bash
xhost +SI:localuser:$(whoami)
```

If you still see *cannot open display* / *X11 connection rejected*, try the same `xhost` line on the desktop.

Pure Wayland-only sessions may need XWayland or different setup; this targets the common X11-on-`:0` case.

To turn off automatic `DISPLAY` / `XAUTHORITY` selection (e.g. headless image with a stale socket): `export ROS2_AUTO_LOCAL_DISPLAY=0` before sourcing, or in the shell profile.

## Build Macro

`build` is the only macro and runs in the **current working directory**.

Requirements for `build`:
- current directory must contain `./src`
- ROS packages are discovered from `./src`

What `build` does:
1. `rosdep install --from-paths ./src ...`
2. installs extra apt dependencies from `apt_packages.txt` in package folders
3. installs extra pip dependencies from `requirements.txt` in package folders
4. runs `colcon build --base-paths ./src`
5. uses distro-scoped artifacts:
   - `build_<ROS_DISTRO>`
   - `install_<ROS_DISTRO>`
   - `log_<ROS_DISTRO>`

Examples:

```bash
# Build all packages found in ./src
build

# Build selected packages (exact colcon package names)
build my_pkg another_pkg
```

## Diagnostic Macro

Use `diag` to quickly print system info and validate environment from `scripts/ros2_env.bash`:

```bash
diag
```

It checks:
- ROS/Cyclone variables are present
- `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`
- `CYCLONEDDS_URI` points to workspace `scripts/cyclone-dds.xml`
- env load marker (`_ROS2_PROJECTS_WS_ENV_LOADED`) is set

## Project Structure

```yaml
scripts/
  distrobox
  ros2_env.bash
  macros.bash
  cyclone-dds.xml
src/
```
