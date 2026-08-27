# scripts/

Workspace entry and three ROS-like bash packages. CLI is always:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
./scripts/setup.bash jazzy prod   # reserved — not implemented yet
```

## Flow

| Command | What runs | Effect |
|---|---|---|
| `./scripts/setup.bash macros` | `bash_bringup` → `macros_session` → `load_macros` | Host shell (Git Bash); macros only, no ROS |
| `./scripts/setup.bash jazzy` | `bash_bringup` → `runtime_dispatch` → `distrobox_enter` → (container) `container_session` → `load_macros` | Distrobox + ROS + macros |
| `./scripts/setup.bash jazzy prod` | `runtime_dispatch` → `docker_enter` | Stub until production runtime exists |

`source scripts/setup.bash macros` loads macros in the current shell instead of opening a new one.

## Layout

```text
setup.bash                              # source-aware wrapper → bash_bringup
bash_bringup/
  launch/bringup.bash                   # CLI router
  src/macros_session.bash               # host macros session
bash_container/
  launch/runtime_dispatch.bash          # Distrobox vs Docker
  src/container_session.bash            # in-container bootstrap (bashrc hook)
  src/distrobox/distrobox_enter.bash
  src/docker/docker_enter.bash          # prod stub
  include/                              # ros2, display
  config/                               # cyclone-dds.xml, *_config.bash
bash_macros/
  launch/load_macros.bash               # load_macros() — root only
  src/build.bash                        # build, cbuild
  src/diag.bash
  include/                              # helpers
```

Convention: one public entry per package under `launch/`; implementation under `src/`.

Macros convention: [bash_macros/README.md](bash_macros/README.md)
