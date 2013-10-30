#!/bin/bash


# ros industrial (rosbuild)
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial/subversion/trunk/swri-ros-pkg":$USER_LIBRARY_PATH
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial/git":$USER_LIBRARY_PATH

# ros industrial training (rosbuild)
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/ref":$USER_LIBRARY_PATH
#export USER_LIBRARY_PATH="$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/supplements":$USER_LIBRARY_PATH
#source "$HOME/Desktop/Projects/ROS/ROS_Industrial_Training/ros_industrial_training/training/.training_units.bash" # training script

# catkin workspaces (Overlays packages previously defined in the ROS_PACKAGE_PATH)
script="$HOME/ros/$ROS_VER/catkin_ws/devel/setup.bash"
if [ -f "$script" ]; then
	source "$script" 
fi

# Setting ROS PACKAGE PATH
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$USER_LIBRARY_PATH

echo "USER_LIBRARY_PATH has been added to the ros path"
