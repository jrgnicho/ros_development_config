#!/bin/bash

ROS_DISTRO="hydro"
# ros industrial training setup (rosbuild)
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/ref":$USER_LIBRARY_PATH
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/supplements":$USER_LIBRARY_PATH
#source "$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/.training_units.bash" # training script

# catkin workspaces 
script="$HOME/ros/$ROS_DISTRO/catkin_ws/devel/setup.bash"
if [ -f "$script" ]; then
	source "$script"
fi

# rosbuild stack/package directories 
USER_LIBRARY_PATH="$HOME/ros/$ROS_DISTRO/rosbuild"

# Setting ROS PACKAGE PATH
if [ -n "$USER_LIBRARY_PATH" ] ; then
	export ROS_PACKAGE_PATH=$USER_LIBRARY_PATH:$ROS_PACKAGE_PATH
fi

echo "USER_LIBRARY_PATH has been added to the ros path"
