#!/bin/bash

BUILD_TOOLS=("catkin-tools" "catkin_make") #(catkin-tools catkin_make)
SELECTED_BUILD_TOOL=""
ROS_DISTRO=""
ROSBUILD_DIR=""
CATKIN_DIR=""
ROS_SETUP_SCRIPT="/opt/ros/$ROS_DISTRO/setup.bash"

function catkin_make_setup()
{
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
}

function catkin_tools_setup()
{
  if [ ! -d $CATKIN_DIR ]; then
	  echo "$(tput setaf 3)CATKIN-TOOLS workspace creation started$(tput sgr0)"
	  mkdir -p "$CATKIN_DIR/src"
    cd "$CATKIN_DIR"
	  catkin init
	  catkin build --jobs 4 --force-cmake --cmake-args -DCMAKE_BUILD_TYPE=Debug
	  echo "$(tput setaf 3)CATKIN-TOOLS workspace creation completed. New workspace location is $CATKIN_DIR$(tput sgr0)"
  else
	  echo "$(tput setaf 3)CATKIN-TOOLS workspace found at location $CATKIN_DIR$(tput sgr0)"
  fi
}

function main()
{

# check arguments
if [[ ( "$#" -lt 3 )]]; then
	echo "$(tput setaf 1)must pass name of ros distribution (hydro, indigo, etc),a catkin workspace name$(tput sgr0) and a build tool"
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

# set ros workspace paths
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
SELECTED_BUILD_TOOL=$3
echo "here $3 ${BUILD_TOOLS[0]} ${BUILD_TOOLS[1]}"
if [ "$SELECTED_BUILD_TOOL" == "${BUILD_TOOLS[0]}" ]; then
  catkin_tools_setup
elif [ "$SELECTED_BUILD_TOOL" == "${BUILD_TOOLS[1]}" ]; then
  catkin_make_setup
else
  echo "$(tput setaf 1)Invalid build tool $SELECTED_BUILD_TOOL selected, exiting$(tput sgr0)" 
fi


# copying ros console config file
if [ ! -f "$CATKIN_DIR/rosconsole.config" ]; then
  # copying default rosconsole config to workspace
  echo "$(tput setaf 3)Copied default rosconsole.config to workspace directory$(tput sgr0)"
  cp "$ROS_ROOT/config/rosconsole.config" "$CATKIN_DIR"
fi

cd $HOME
}


main "$@"

