#!/bin/bash

# variables
CATKIN_WS="catkin_ws"
CUSTOM_SETUP_SCRIPT="env.bash"

# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (groovy, hydro, indigo, etc) $(tput sgr0)"
	exit
else
	ROS_DISTRO=$1
fi 

if [[ ( "$#" -ge 2 )]]; then
	CATKIN_WS=$2
fi

# ros workpace setup variables
ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"
CATKIN_DIR="$HOME/ros/$ROS_DISTRO/$CATKIN_WS"

# check catkin workspace directory
if [ ! -d "$CATKIN_DIR" ]; then
	echo "$(tput setaf 1)The catkin workspace ($CATKIN_DIR) does not exits $(tput sgr0)"
	exit 
fi

# ros system setup script
source "/opt/ros/$ROS_DISTRO/setup.bash"

# ros catkin workspace setup script (default)
WS_SETUP_SCRIPT="$CATKIN_DIR/devel/setup.bash"

# check in case devel directory isn't default
devel_dir=`catkin locate -w $CATKIN_DIR -d 2> /dev/null`
if [ -n "$devel_dir" ]; then
  WS_SETUP_SCRIPT="$devel_dir/setup.bash"
fi

if ! [ -f "$WS_SETUP_SCRIPT" ]; then
	echo "$(tput setaf 1)Error sourcing the catkin workspace setup script $WS_SETUP_SCRIPT$(tput sgr0)"
  exit 1
fi

# source workspace now
CUSTOM_SETUP_SCRIPT_PATH="$CATKIN_DIR/$CUSTOM_SETUP_SCRIPT"
source "$CUSTOM_SETUP_SCRIPT_PATH"

# rosbuild workspace setup
USER_LIBRARY_PATH="$HOME/ros/$ROS_DISTRO/rosbuild"

# Setting ROS PACKAGE PATH
if [ -n "$USER_LIBRARY_PATH" ] ; then
	export ROS_PACKAGE_PATH=$USER_LIBRARY_PATH:$ROS_PACKAGE_PATH
fi

# setting up ros environment variables
export MAKEFLAGS="-j1"
export ROS_WORKSPACE="$CATKIN_DIR"
export ROS_LOCATIONS="ws=$CATKIN_DIR:src=$CATKIN_DIR/src:rosbuild=$ROSBUILD_DIR:ros_development_config=$HOME/ros_development_config"
export ROSCONSOLE_CONFIG_FILE="$CATKIN_DIR/rosconsole.config"
export ROS_PARALLEL_JOBS="-j2 -l2"
export PYTHONPATH="$PYTHONPATH:$CATKIN_DIR/src:$ROSBUILD_DIR"
export ROSCONSOLE_FORMAT='[${severity}]: ${message};'
alias env_source="source $CUSTOM_SETUP_SCRIPT_PATH"
alias create_eclipse_proj="$HOME/ros_development_config/eclipse/create_ros1_eclipse_project.py"

PS1="$CATKIN_WS[ros-$ROS_DISTRO]: "
echo "$(tput setaf 3)ROS \"$CATKIN_WS\" workspace is ready$(tput sgr0)"
