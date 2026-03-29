# Source the ROS 2 setup script on each activation.
# local_setup.bash only sources one level of underlay
source /opt/ros/$ROS_DISTRO/local_setup.bash

# Source the development workspace setup script if available.
# Prefer distro-specific overlays to avoid Humble/Jazzy collisions.
overlay_install_dir="$_KALMAN_WS_ROOT/install_${ROS_DISTRO}"
if [ -f "$overlay_install_dir/local_setup.bash" ]; then
    source "$overlay_install_dir/local_setup.bash"
elif [ -f "$_KALMAN_WS_ROOT/install/local_setup.bash" ]; then
    # Backward compatibility with old single-distro workspace layout.
    source "$_KALMAN_WS_ROOT/install/local_setup.bash"
fi
