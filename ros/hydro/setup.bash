#!/bin/bash
ROS_DISTRO="hydro"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_core_setup.bash"
source "$HOME/linux_config/general/ros_create_workspace.bash" $ROS_DISTRO
#source "$HOME/linux_config/ros/$ROS_DISTRO/ros_android_setup.bash"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_user_libs_setup.bash"
PS1="ros-$ROS_DISTRO: "
