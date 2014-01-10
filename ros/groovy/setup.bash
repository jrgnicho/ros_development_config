#!/bin/bash
ROS_DISTRO="groovy"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_core_setup.bash"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_user_libs_setup.bash"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_android_setup.bash"
PS1="ros-$ROS_DISTRO: "
