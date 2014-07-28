#!/bin/bash

ROS_DISTRO=""
# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (groovy, hydro, etc)$(tput sgr0)"
	exit
else
	ROS_DISTRO=$1
fi 

# default ros workspace paths
ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"
CATKIN_DIR="$HOME/ros/$ROS_DISTRO/catkin_ws"

# check arguments for ros workspace paths
if [[ ( "$#" -gt 1 )]]; then
	CATKIN_DIR=$2
fi

if [[ ( "$#" -gt 2 )]]; then
	ROSBUILD_DIR=$3
fi

#create rosbuild
if [ ! -d $ROSBUILD_DIR ]; then
	mkdir -p $ROSBUILD_DIR
	echo "$(tput setaf 3)ROSBUILD workspace was created at location $ROSBUILD_DIR$(tput sgr0)"
	
else
	echo "$(tput setaf 3)ROSBUILD workspace found at location $ROSBUILD_DIR$(tput sgr0)"
fi

#create catkin
if [ ! -d $CATKIN_DIR ]; then
	echo "$(tput setaf 3)CATKIN workspace will be created at location $CATKIN_DIR$(tput sgr0)"
	mkdir -p "$CATKIN_DIR/src"
	cd "$CATKIN_DIR/src"
	catkin_init_workspace
	cd ..
	catkin_make
	echo "$(tput setaf 3)CATKIN workspace was created at location $CATKIN_DIR$(tput sgr0)"
else
	echo "$(tput setaf 3)CATKIN workspace found at location $CATKIN_DIR$(tput sgr0)"
fi


cd $HOME
