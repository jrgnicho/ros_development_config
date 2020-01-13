#!/bin/bash

# variables
ROS2_WS="ROS2_WS"

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


if [ -f "$ROS2WS_SOURCE_SCRIPT" ]; then
	source "$ROS2WS_SOURCE_SCRIPT"
else
	echo "$(tput setaf 1)Error sourcing the ros2 workspace setup script $ROS2WS_SOURCE_SCRIPT$(tput sgr0)"
fi

# rosbuild workspace setup
USER_LIBRARY_PATH="$HOME/ros/$ROS2_DISTRO/rosbuild"

# setting up ros environment variables
export MAKEFLAGS="-j1"
export ROS_WORKSPACE="$ROS2WS_DIR"
export ROS_LOCATIONS="ws=$ROS2WS_DIR:src=$ROS2WS_DIR/src:ros_development_config=$HOME/ros_development_config"
export ROSCONSOLE_CONFIG_FILE="$ROS2WS_DIR/rosconsole.config"
export ROS_PARALLEL_JOBS="-j2 -l2"
export PYTHONPATH="$PYTHONPATH:$ROS2WS_DIR/src"
export ROSCONSOLE_FORMAT='[${severity}]: ${message};'
export COLCON_HOME="$COLCON_HOME"
alias ros2ws_source=". $ROS2WS_SOURCE_SCRIPT"

# check directory for optional configuration scripts
OPTIONAL_CONF_SCRIPT="$LINUX_CONF_PATH/ros/$ROS2_DISTRO/setup.bash"
if [ -f "$OPTIONAL_CONF_SCRIPT" ]; then
	echo "$(tput setaf 3)Sourcing optional configuration script '$OPTIONAL_CONF_SCRIPT' $(tput sgr0)"
  source "$OPTIONAL_CONF_SCRIPT"
fi

cd "$ROS2WS_DIR"
PS1="ros2-$ROS2_DISTRO: "
echo "$(tput setaf 3)ROS $ROS2_DISTRO is ready$(tput sgr0)"
