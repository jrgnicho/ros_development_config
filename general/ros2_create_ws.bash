#!/bin/bash

BUILD_TOOLS=("colcon") 
SELECTED_BUILD_TOOL=""
ROS_DISTRO=""
ROS2_WS_DIR=""
ROS_SETUP_SCRIPT="/opt/ros/$ROS_DISTRO/setup.bash"
CLANG_FORMAT_FILE="$HOME/ros_development_config/eclipse/formatters/.clang-format"

function colcon_setup()
{
  if [ ! -d $ROS2_WS_DIR ]; then
	  echo "$(tput setaf 3)ROS2 workspace creation started$(tput sgr0)"
	  mkdir -p "$ROS2_WS_DIR/src"
    cd "$ROS2_WS_DIR"
	  colcon build --symlink-install
	  echo "$(tput setaf 3)ROS2 workspace creation completed. New workspace location is $ROS2_WS_DIR$(tput sgr0)"
  else
	  echo "$(tput setaf 3)ROS2 workspace found at location $ROS2_WS_DIR, skip creation.$(tput sgr0)"
  fi
}

function main()
{
	# check arguments
	if [[ ( "$#" -lt 3 )]]; then
		echo "$(tput setaf 1)must pass name of ros distribution (bouncy, crystal, dashing, ...),a ros2 workspace name$(tput sgr0) and a build tool"
		exit
	else
		ROS_DISTRO=$1
	fi 
	
	ROS_SETUP_SCRIPT="/opt/ros2/$ROS_DISTRO/setup.bash"
	if [ -f $ROS_SETUP_SCRIPT ]; then
	  source "$ROS_SETUP_SCRIPT"
	else
	  echo "$(tput setaf 1)ros-$ROS_DISTRO has not been installed, aborting$(tput sgr0)"
	  exit
	fi
	
	# set ros workspace paths
	ROS2_WS_DIR="$HOME/ros/$ROS_DISTRO/$2"
	
	#create ros2 ws
	SELECTED_BUILD_TOOL=$3
	if [ "$SELECTED_BUILD_TOOL" == "${BUILD_TOOLS[0]}" ]; then
	  colcon_setup 
	else
	  echo "$(tput setaf 1)Invalid build tool $SELECTED_BUILD_TOOL selected, exiting$(tput sgr0)" 
	fi
	
	### Copying files to workspace
	# copying ros console config file
	if [ ! -f "$ROS2_WS_DIR/rosconsole.config" ]; then
	  # copying default rosconsole config to workspace
	  cp "$ROS_ROOT/config/rosconsole.config" "$ROS2_WS_DIR"
	  echo "$(tput setaf 3)Copied default rosconsole.config to workspace directory$(tput sgr0)"
	fi
	
	# copying ros console config file
	if [ ! -f "$ROS2_WS_DIR/.clang-format" ]; then
	  # copying default .clang-format to workspace
	  cp "$CLANG_FORMAT_FILE" "$ROS2_WS_DIR"
	  echo "$(tput setaf 3)Copied default .clang-format to workspace directory$(tput sgr0)"
	fi
	
	
	cd $HOME
}


main "$@"

