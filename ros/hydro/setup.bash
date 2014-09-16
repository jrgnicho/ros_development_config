#!/bin/bash
CATKIN_WS="catkin_ws"
ROS_DISTRO="hydro"

if [[ ( "$#" -ge 1 )]]; then
	CATKIN_WS=$1
fi

source "$HOME/linux_config/general/ros_core_setup.bash" $ROS_DISTRO $CATKIN_WS
#source "$HOME/linux_config/ros/$ROS_DISTRO/ros_android_setup.bash"
source "$HOME/linux_config/ros/$ROS_DISTRO/ros_user_libs_setup.bash"
