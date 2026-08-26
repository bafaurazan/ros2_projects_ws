---
name: ros2-build
description: Build ROS 2 packages in this workspace with build (deps + colcon) or cbuild (colcon only). Use when compiling, installing dependencies, or choosing between build and cbuild.
---

# ROS 2 build

Work inside Distrobox (`./scripts/setup.bash humble` or `jazzy`). Host `macros` mode has no ROS.

## Where to run

`cd` to the directory that contains `./src` (the colcon scan path), then:

```bash
build                      # rosdep + apt + pip, then cbuild
build --packages-select pkg
cbuild                     # colcon only
cbuild --packages-select pkg
```

## Artifacts

Colcon writes to `./build_ws/` in the current directory:

- `build_<ROS_DISTRO>/`
- `install_<ROS_DISTRO>/`
- `log_<ROS_DISTRO>/`

Then `cbuild` sources `install_<ROS_DISTRO>/local_setup.bash`. Deleting `./build_ws` removes that project's build trees only.

## Choose

- First time or after dependency changes → `build`
- Iterate on code only → `cbuild`

Do not invent a parallel colcon layout. Extra arguments are passed through to `colcon build`.
