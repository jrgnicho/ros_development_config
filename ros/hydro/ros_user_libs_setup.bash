#!/bin/bash


# ros industrial training setup (rosbuild)
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/ref":$USER_LIBRARY_PATH
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/supplements":$USER_LIBRARY_PATH
#source "$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/.training_units.bash" # training script

# catkin workspaces 
script="$HOME/ros/$ROS_VER/catkin_ws/devel/setup.bash"
if [ -f "$script" ]; then
	source "$script"
fi

# rosbuild stack/package directories 
USER_LIBRARY_PATH="$HOME/ros/$ROS_VER/rosbuild"

# Setting ROS PACKAGE PATH
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$USER_LIBRARY_PATH

echo "USER_LIBRARY_PATH has been added to the ros path"