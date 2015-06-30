#!/bin/bash

ROS_DISTRO=""
# check arguments
if [[ ( "$#" -lt 2 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (hydro, indigo, etc) and catkin workspace name$(tput sgr0)"
	exit
else
	ROS_DISTRO=$1
fi 

ROS_SETUP_SCRIPT="/opt/ros/$ROS_DISTRO/setup.bash"
if [ -f $ROS_SETUP_SCRIPT ]; then
  source "$ROS_SETUP_SCRIPT"
else
  echo "$(tput setaf 1)ros-$ROS_DISTRO has not been installed, aborting$(tput sgr0)"
  exit
fi

# default ros workspace paths
ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"
CATKIN_DIR="$HOME/ros/$ROS_DISTRO/$2"

#create rosbuild
if [ ! -d $ROSBUILD_DIR ]; then
	mkdir -p $ROSBUILD_DIR
	echo "$(tput setaf 3)ROSBUILD workspace was created at location $ROSBUILD_DIR$(tput sgr0)"
	
else
	echo "$(tput setaf 3)ROSBUILD workspace found at location $ROSBUILD_DIR$(tput sgr0)"
fi

#create catkin
if [ ! -d $CATKIN_DIR ]; then
	echo "$(tput setaf 3)CATKIN workspace creation started$(tput sgr0)"
	mkdir -p "$CATKIN_DIR/src"
	cd "$CATKIN_DIR/src"
	catkin_init_workspace
	cd ..
	catkin_make
	echo "$(tput setaf 3)CATKIN workspace creation completed. New workspace location is $CATKIN_DIR$(tput sgr0)"
else
	echo "$(tput setaf 3)CATKIN workspace found at location $CATKIN_DIR$(tput sgr0)"
fi

# copying ros console config file
if [ ! -f "$CATKIN_DIR/rosconsole.config" ]; then
  # copying default rosconsole config to workspace
  echo "$(tput setaf 3)Copied default rosconsole.config to workspace directory$(tput sgr0)"
  cp "$ROS_ROOT/config/rosconsole.config" "$CATKIN_DIR"
fi



cd $HOME
