#!/bin/bash

# variables
CATKIN_WS="catkin_ws"

# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (groovy, hydro, indigo, etc) $(tput sgr0)"
	exit
else
	ROS_DISTRO=$1
fi 

if [[ ( "$#" -eq 2 )]]; then
	CATKIN_WS=$2
fi

# ros workpace setup variables
ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"
CATKIN_DIR="$HOME/ros/$ROS_DISTRO/$CATKIN_WS"

# check directory for configuration scripts
if [ ! -d "$LINUX_CONF_PATH/ros/$ROS_DISTRO" ]; then
	echo "$(tput setaf 1)This distribution of ros ($ROS_DISTRO) has not been setup with configuration scripts $(tput sgr0)"
	exit 
fi

# check catkin workspace directory
if [ ! -d "$CATKIN_DIR" ]; then
	echo "$(tput setaf 1)The catkin workspace ($CATKIN_DIR) does not exits $(tput sgr0)"
	exit 
fi

# ros system setup script
source "/opt/ros/$ROS_DISTRO/setup.bash"

# ros workspaces initialization
source "$HOME/linux_config/general/ros_create_workspace.bash" $ROS_DISTRO $CATKIN_DIR $ROSBUILD_DIR

# ros catkin workspace setup
script="$HOME/ros/$ROS_DISTRO/catkin_ws/devel/setup.bash"
if [ -f "$script" ]; then
	source "$script"
else
	echo "$(tput setaf 1)Error sourcing the catkin workspace setup script.$(tput sgr0)"
fi

# rosbuild workspace setup
USER_LIBRARY_PATH="$HOME/ros/$ROS_DISTRO/rosbuild"

# Setting ROS PACKAGE PATH
if [ -n "$USER_LIBRARY_PATH" ] ; then
	export ROS_PACKAGE_PATH=$USER_LIBRARY_PATH:$ROS_PACKAGE_PATH
fi

# setting up ros environment variables
export MAKEFLAGS="-j1"
export ROS_WORKSPACE="$CATKIN_DIR"
export ROS_LOCATIONS="catkin_ws=$CATKIN_DIR:rosbuild=$ROSBUILD_DIR:linux_config=$HOME/linux_config/ros/hydro"
export ROS_PARALLEL_JOBS="-j2 -l2"
export PYTHONPATH="$PYTHONPATH:$CATKIN_DIR/src:$ROSBUILD_DIR"
PS1="ros-$ROS_DISTRO: "
echo "$(tput setaf 3)ROS $ROS_DISTRO is ready$(tput sgr0)"
