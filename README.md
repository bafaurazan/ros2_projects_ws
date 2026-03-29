# Knml Workspace

ROS 2 development environment for `knml_rover` and future ROS projects.

## Prerequisites

If you wish to use a Docker container:
- [Docker](https://www.docker.com) or alternatively [Podman](https://podman.io)
- [Distrobox](https://github.com/89luca89/distrobox)

If you wish to develop natively on your Ubuntu Jammy:
- [ROS 2 Humble](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html)
- [Python 3](https://www.python.org) along with `python-is-python3`

## Getting Started

Firstly clone the repository on your machine:
```bash
git clone --recurse-submodules git@github.com:knmlprz/knml_ws.git
```

If you have already cloned without `--recurse-submodules`, use:
```bash
git submodule update --init --recursive
```

### Containerized Development

To enter the ROS 2 shell, run this automated script with a distro selector:
```bash
./scripts/distrobox humble
# or
./scripts/distrobox jazzy
```
A distrobox dedicated to the selected distro will be created (if needed) and you will be logged in automatically.

After the initial setup of your container is done, you will be able to use ROS 2 and graphical tools such as Rviz and Rqt.

#### Building the Workspace

This repository includes `knml_rover` repository as a submodule, but it might not always be up to date.
Therefore, after your distrobox is ready, you should pull the latest changes from the remote repository:

```bash
cd src/knml_rover
git checkout main
git pull
cd ../..
```

Now you can build the workspace. `knml_ws` provides a useful macro that can be used to automate this process. It can be typed right into the terminal:

```bash
build
```

Running this command will install all rosdeps, custom APT/PIP dependencies, build the workspace, and source it.
Build artifacts are separated by distro and saved into `build_<distro>`, `install_<distro>`, and `log_<distro>`.
Visual Studio Code initialization is currently disabled, because VS Code is not used at the moment.

After the workspace is built, please visit [knml_rover](https://github.com/knmlprz/knml_rover/tree/main#) repository for instructions on how to start the robot.

### Native Ubuntu Development

If you do not wish to use a container, you can still make use of most of the features offered by `knml_ws`.
- In order to setup your environment, you should first instal all the necessary dependencies listed in the corresponding subsection of [Prerequisites](#prerequisites).
- After that, you can enable all the macros normally available in Distrobox by sourcing the `./scripts/setup.bash` script from a Bash shell.
For deployment, this script should be sourced from within the `.bashrc` file.

In this alternate configuration, source `./scripts/setup.bash` manually in your shell session (VS Code integration is currently disabled).


## Custom Macros

- `build` - Pull from rosdep and build the workspace, then source its setup script.
- `clean` - Remove build artifacts from the workspace.
- `format` - Run `clang-format` and `black` on all packages in the workspace.

See: [macros.bash](/scripts/macros.bash)

## Coding Guidelines

- Make sure that your Colcon packages do not depend on this workspace repository. This includes for instance referring to environment variables exported by the setup scripts or assuming that your package will always be located under `src/`.

## Project Structure

```yaml
├─ .distrobox_humble/     # Distrobox home for ROS 2 Humble (ignored)
├─ .distrobox_jazzy/      # Distrobox home for ROS 2 Jazzy (ignored)
├─ .vscode/               # Visual Studio Code configuration (ignored)
├─ build_humble/          # ROS 2 Humble build artifacts (ignored)
├─ install_humble/        # ROS 2 Humble install artifacts (ignored)
├─ log_humble/            # ROS 2 Humble runtime artifacts (ignored)
├─ build_jazzy/           # ROS 2 Jazzy build artifacts (ignored)
├─ install_jazzy/         # ROS 2 Jazzy install artifacts (ignored)
├─ log_jazzy/             # ROS 2 Jazzy runtime artifacts (ignored)
├─ scripts/               # The implementation of the workspace
│  ├─ .bashrc             # Knml dev env Bash overlay; Can be sourced both from Distrobox or from a standalone system.
│  ├─ configure_vscode.py # Visual Studio auto-complete configuration script; called from macros.bash
│  ├─ Dockerfile          # ROS 2 (Desktop) image recipe; Does not assume Distrobox.
│  ├─ distrobox           # Distrobox launch script
│  └─ macros.bash         # Implements useful development macros; included by .bashrc
└─ src/                   # the package directory
   └─ knml_rover/         # a single submodule for all packages that make up Knml's software stack
```
