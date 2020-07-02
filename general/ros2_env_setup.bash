#!/bin/bash

# variables
ROS2_WS="ROS2_WS"
CUSTOM_SETUP_SCRIPT="env.bash"

# check arguments
if [[ ( "$#" -lt 1 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (groovy, hydro, indigo, etc) $(tput sgr0)"
	exit -1
else
	ROS2_DISTRO=$1
fi 

if [[ ( "$#" -ge 2 )]]; then
	ROS2_WS=$2
fi

# ros workpace setup variables
ROS2WS_DIR="$HOME/ros2/$ROS2_DISTRO/$ROS2_WS"

# check ros2 workspace directory
if [ ! -d "$ROS2WS_DIR" ]; then
	echo "$(tput setaf 1)The ros2 workspace ($ROS2WS_DIR) does not exits $(tput sgr0)"
	exit -1
fi

# check colcon home
COLCON_HOME="$ROS2WS_DIR/.colcon"
if [ ! -d "$COLCON_HOME" ]; then
  mkdir -p $COLCON_HOME
fi

# ros system setup script
source "/opt/ros/$ROS2_DISTRO/setup.bash"

# ros2 workspace setup script (default)
ROS2WS_SOURCE_SCRIPT="$ROS2WS_DIR/install/setup.bash"
COLCON_SETUP_SCRIPT="$LINUX_CONF_PATH/general/colcon_ws_setup.py"

if ! [ -f "$ROS2WS_SOURCE_SCRIPT" ]; then
	echo "$(tput setaf 1)Error sourcing the ros2 workspace setup script $ROS2WS_SOURCE_SCRIPT$(tput sgr0)"
  exit 1
fi

# source workspace now
CUSTOM_SETUP_SCRIPT_PATH="$ROS2WS_DIR/$CUSTOM_SETUP_SCRIPT"
source "$CUSTOM_SETUP_SCRIPT_PATH"

# setting up ros environment variables and aliases
export COLCON_HOME="$ROS2WS_DIR"
alias ros2ws_source=". $CUSTOM_SETUP_SCRIPT_PATH"  # used to source the workspace and user defined env variables
alias colcon_ws_setup="python3 $COLCON_SETUP_SCRIPT"  # used to setup colcon mixin (optional)

cd "$ROS2WS_DIR"
PS1="$ROS2_WS[ros2-$ROS2_DISTRO]: "
echo "$(tput setaf 3)ROS2 \"$ROS2_WS\" workspace is ready$(tput sgr0)"
