# Find the root of the Kalman workspace.
export _KALMAN_WS_ROOT=$(realpath $(dirname $BASH_SOURCE)/..)

# Enable global pip.
export PIP_BREAK_SYSTEM_PACKAGES=1

# Currently Cyclone appears more stable and predictable under high load than eProsima FastDDS:
# Ensure that Cyclone DDS is installed.
if [ ! -f "/opt/ros/$ROS_DISTRO/lib/librmw_cyclonedds_cpp.so" ]; then
    echo "Cyclone DDS is not installed. Installing..."
    sudo apt-get install -y ros-$ROS_DISTRO-rmw-cyclonedds-cpp
fi
# Enable Cyclone DDS.
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI="file://$_KALMAN_WS_ROOT/scripts/cyclone-dds.xml"

# Enable NodeJS v20 repo.
if [ ! -f "/etc/apt/sources.list.d/nodesource.list" ]; then
    echo "NodeJS v20 repo is not installed. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
fi

# Install spacenavd if not available.
if [ ! -f "/usr/bin/spacenavd" ]; then
    echo "spacenavd is not installed. Installing..."
    sudo apt-get install -y spacenavd
fi
# Quietly start spacenavd if not started.
if [ ! -f "/run/spnavd.pid" ]; then
    sudo start-stop-daemon --start --pidfile /run/spnavd.pid --exec /usr/bin/spacenavd -- -v
fi

# Enable colored ROS output.
export RCUTILS_COLORIZED_OUTPUT=1

# Include all other setup scripts.
source $_KALMAN_WS_ROOT/scripts/source-ros-setups.bash
source $_KALMAN_WS_ROOT/scripts/macros.bash
source $_KALMAN_WS_ROOT/scripts/kalm.bash

# Restore apt/sudo tab-completion after ROS argcomplete registration.
# ROS setup may install a global Python completer that shadows command-specific completions.
if [[ $- == *i* ]]; then
    # Make package completion visible with a single TAB in interactive shells.
    bind 'set show-all-if-ambiguous on'
    bind 'set completion-query-items 0'

    if [ -f "/usr/share/bash-completion/completions/apt" ]; then
        source "/usr/share/bash-completion/completions/apt"
    fi
    if [ -f "/usr/share/bash-completion/completions/sudo" ]; then
        source "/usr/share/bash-completion/completions/sudo"
    fi

    # Force command-specific completion handlers even if a global fallback
    # completer was registered earlier (e.g. by ROS Python argcomplete).
    if declare -F _apt >/dev/null 2>&1; then
        complete -F _apt apt
    fi
    if declare -F _sudo >/dev/null 2>&1; then
        complete -F _sudo sudo
    fi

    # Some apt completion versions use "apt-cache --no-generate", which can fail
    # on certain images and return no candidates at all. Provide a robust fallback.
    if ! apt-cache --no-generate pkgnames bash >/dev/null 2>&1; then
        _ros2_projects_ws_apt_complete() {
            local cur prev words cword
            if declare -F _init_completion >/dev/null 2>&1; then
                _init_completion || return
            else
                cur="${COMP_WORDS[COMP_CWORD]}"
                words=("${COMP_WORDS[@]}")
                cword="$COMP_CWORD"
            fi

            local apt_cmd=""
            local i
            for ((i=1; i <= cword; i++)); do
                case "${words[i]}" in
                    install|reinstall|remove|purge|show|list|download|changelog|depends|rdepends|source|build-dep|showsrc|policy)
                        apt_cmd="${words[i]}"
                        break
                        ;;
                esac
            done

            if [[ "$cur" == -* ]]; then
                return 0
            fi

            case "$apt_cmd" in
                install|reinstall|show|list|download|changelog|depends|rdepends|source|build-dep|showsrc|policy)
                    COMPREPLY=($(apt-cache pkgnames "$cur" 2>/dev/null))
                    ;;
                remove|purge)
                    if declare -F _comp_dpkg_installed_packages >/dev/null 2>&1 && declare -F _xfunc >/dev/null 2>&1; then
                        COMPREPLY=($(_xfunc dpkg _comp_dpkg_installed_packages "$cur"))
                    else
                        COMPREPLY=($(dpkg-query -W -f='${binary:Package}\n' 2>/dev/null | grep "^$cur"))
                    fi
                    ;;
                *)
                    COMPREPLY=($(compgen -W "install reinstall remove purge update upgrade full-upgrade dist-upgrade list search show showsrc source build-dep download depends rdepends policy autoremove autopurge clean autoclean" -- "$cur"))
                    ;;
            esac
            return 0
        }

        complete -F _ros2_projects_ws_apt_complete apt
        complete -F _ros2_projects_ws_apt_complete apt-get
    fi
fi

# Make sure that rosdep cache exists.
if [ ! -d "$HOME/.ros/rosdep" ]; then
    # Update rosdep index.
    echo "Updating rosdep index..."
    rosdep update --rosdistro $ROS_DISTRO --default-yes
fi
