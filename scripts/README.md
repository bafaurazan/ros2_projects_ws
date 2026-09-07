# scripts/

Workspace entry and three ROS-like bash packages. CLI is always:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
./scripts/setup.bash jazzy prod   # reserved — not implemented yet
```

`humble` / `jazzy` (Distrobox) require **native Linux**. On Windows/Git Bash or WSL they exit with an error; use `macros` for host helpers.

## Flow

| Command | What runs | Effect |
|---|---|---|
| `./scripts/setup.bash macros` | `bash_bringup` → `bash_env` → `run_macros` → `load_macros` | Host shell (Git Bash); macros only, no ROS |
| `./scripts/setup.bash jazzy` | `bash_bringup` → `bash_env` → `run_distrobox` (host) → sourced again in-container → `load_macros` | Distrobox + ROS + macros |
| `./scripts/setup.bash jazzy prod` | `bash_env` → `run_docker` | Stub until production runtime exists |

`source scripts/setup.bash macros` loads macros in the current shell instead of opening a new one.

## Layout

```text
setup.bash                              # source-aware wrapper → bash_bringup
bash_bringup/
  launch/bringup.bash                   # main entry → include + src
  src/dispatch.bash                     # hand-off to bash_env
  include/                              # bringup helpers
bash_env/
  launch/runtime_dispatch.bash          # macros | Distrobox | Docker
  launch/backends/run_macros.bash       # host macros (+ --rcfile / source)
  launch/backends/run_distrobox.bash    # host create/enter + in-container boot
  launch/backends/run_docker.bash       # prod stub + in-image session template
  src/impl_distrobox.bash               # Distrobox functions
  src/impl_docker.bash                  # prod stub functions
  include/                              # ros2, display, platform, macros helpers
  config/                               # cyclone-dds.xml, *_config.bash
bash_macros/
  launch/macros.bash                    # @macros registry + source lib/bundle_load.bash
  src/                                  # build, cbuild, diag, load_macros, importer
  include/                              # namespaced helpers (ns::_)
  lib/                                  # bundle_load + TAB completion
  config/                               # importer.repos
```

Macros convention: [bash_macros/README.md](bash_macros/README.md). Helpers in `bash_bringup` / `bash_env` use the same `ns::_name` form (`bringup::` / `env::`).
