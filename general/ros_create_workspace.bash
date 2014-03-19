#!/bin/bash

ROS_DISTRO=""
# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "must pass name of ros distribution (groovy, hydro, etc)"
	exit
else
	ROS_DISTRO=$1
fi 

ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"
CATKIN_DIR="$HOME/ros/$ROS_DISTRO/catkin_ws"

#create rosbuild
if [ ! -d $ROSBUILD_DIR ]; then
	mkdir -p $ROSBUILD_DIR
	echo "ROSBUILD workspace was created at location $ROSBUILD_DIR"
	
else
	echo "ROSBUILD workspace found at location $ROSBUILD_DIR"
fi

#create catkin
if [ ! -d $CATKIN_DIR ]; then
	echo "CATKIN workspace will be created at location $CATKIN_DIR"
	mkdir -p "$CATKIN_DIR/src"
	cd "$CATKIN_DIR/src"
	catkin_init_workspace
	cd ..
	catkin_make
	echo "CATKIN workspace was created at location $CATKIN_DIR"
else
	echo "CATKIN workspace found at location $CATKIN_DIR"
fi


cd $HOME
