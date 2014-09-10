#!/bin/bash

ROS_DISTRO=""
PROFILE="Default"
CATKIN_WS="catkin_ws"


# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "must pass name of ros distribution (groovy, hydro)"
	exit
else
	ROS_DISTRO=$1
fi 

if [[ ( "$#" -ge 2 )]]; then
	PROFILE=$2
fi

# check selected workspace env variable
if [ ! -z "$SELECTED_CATKIN_WS" ]; then
	CATKIN_WS=$SELECTED_CATKIN_WS
fi
	

# check directory
if [ ! -d "$LINUX_CONF_PATH/ros/$ROS_DISTRO" ]; then
	echo "This distribution of ros ($ROS_DISTRO) has not been setup with configuration scripts"
	exit 
fi

# construct bash file
cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
echo "source $LINUX_CONF_PATH/ros/$ROS_DISTRO/setup.bash">>"$LINUX_CONF_PATH/bashrc.tmp"
ARG="--tab-with-profile=$PROFILE --command='bash --rcfile $LINUX_CONF_PATH/bashrc.tmp'"
COMMAND="gnome-terminal --title=ros-$ROS_DISTRO $ARG $ARG $ARG $ARG $ARG $ARG $ARG"

eval $COMMAND
