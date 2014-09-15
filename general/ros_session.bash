#!/bin/bash

ROS_DISTRO=""
PROFILE="Default"
CATKIN_WS="catkin_ws"

SHORT_OPTIONS="r:w:l:p:h"
LONG_OPTIONS="ros-distro:,workspace:,list-workspaces:profile:help"
HELP_TEXT="Usage:\n
\t -r|--ros-distro [ros-distro] -w|--workspace [workspace name] 
\t -l|--list-workspaces\n
\t -h|--help \n"


function check_supported_ros_distro()
{
	ros_distro=$1
	
	# check directory
	if [ ! -d "$LINUX_CONF_PATH/ros/$ros_distro" ]; then		
		return 1 
	else
		return 0
	fi
}

function check_catkin_workspace_exists()
{
	catkin_dir="$HOME/ros/$2/$1"

	# check directory
	if [ ! -d "$catkin_dir" ]; then		
		return 1 
	else
		return 0
	fi
}

function get_workspace_list()
{
	ros_distro=$1
	ros_dir="$HOME/ros/$1"
	local -a a=()

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return
	fi

	# iterating through directories
	counter=0
	for d in $(ls -d $ros_dir/*); do
		catkin_ws=$(basename $d)

		# skip rosbuild
		if [ $catkin_ws == "rosbuild" ]; then
			continue
		fi

		# add ws to array
		a[$counter]=$catkin_ws
		let counter=counter+1

	done

	echo ${a[@]}
}

function list_catkin_workspaces()
{
	ros_distro=$1
	ros_dir="$HOME/ros/$1"

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return 1
	fi

	declare -a a=()
	a=$(get_workspace_list $ros_distro)

	for i in ${a[@]}; do
		echo "ros catkin workspace: $i"
	done

	return 0
}

function main()
{
	PARSED_OPTIONS=$(getopt -n "$0" -o $SHORT_OPTIONS --long $LONG_OPTIONS -- "$@")

	#Bad arguments, something has gone wrong with the getopt command.
	if [ $? -ne 0 ];
	then
		exit 1
	fi
	 
	# A little magic, necessary when using getopt.
	eval set -- "$PARSED_OPTIONS"		

	while true; do
		OPTARG=$2		
		case "$1" in
			-r|--ros-distro)
				echo "ros-distro selected $OPTARG"
				ROS_DISTRO=$OPTARG
				shift 2
				;;

			-w|--workspace)
				echo "catkin workspace selected $OPTARG"
				CATKIN_WS=$OPTARG
				shift 2
				;;

			-l|--list-workspaces)

				if(! list_catkin_workspaces $OPTARG); then
					echo "ros $2 has no catkin workspaces"
					exit 1
				else
					exit 0
				fi
				;;

			-h|--help)
				$(echo -e $HELP_TEXT)
				shift 2
				;;

			-p|--profile)

				PROFILE=$OPTARG
				shift 2
				;;

			--)
				#echo "finished parsing options"
				break;;


		esac
	
		let OPTIND=OPTIND+1
	done

	echo "Arguments: $@"

	# positional arg ros-distro
	if [ $# -ge 2 ]; then
		ROS_DISTRO=$2
	fi

	# positional arg workspace
	if [ $# -ge 3 ]; then
		CATKIN_WS=$3
	fi

		# positional arg profile
	if [ $# -ge 4 ]; then
		PROFILE=$4
	fi

	# check ros distro
	if(! check_supported_ros_distro $ROS_DISTRO); then
		echo "$(tput setaf 1)Configuration scripts for ros $ROS_DISTRO not found$(tput sgr0)"
		exit 1
	fi

	# check catkin workspace
	if(! check_catkin_workspace_exists $CATKIN_WS $ROS_DISTRO); then
		echo "Catkin workspace $CATKIN_WS for ros $ROS_DISTRO was not found"
		exit 1
	fi

	# construct bash file
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
	echo "source $LINUX_CONF_PATH/ros/$ROS_DISTRO/setup.bash $CATKIN_WS">>"$LINUX_CONF_PATH/bashrc.tmp"
	ARG="--tab-with-profile=$PROFILE --command='bash --rcfile $LINUX_CONF_PATH/bashrc.tmp'"
	COMMAND="gnome-terminal --title=ros-$ROS_DISTRO $ARG $ARG $ARG $ARG $ARG $ARG $ARG"

	eval $COMMAND
}

main "$@"
