#!/bin/bash


# variables
SELECTED_CATKIN_WS=""
SELECTED_ROS_DISTRO=""

function check_valid_ros_distro()
{
	ros_distro=$1
	
	# check directory
	if [ ! -d "$LINUX_CONF_PATH/ros/$ros_distro" ]; then		
		return 1 
	else
		#echo $LINUX_CONF_PATH/ros/$ros_distro
		return 0
	fi
}

function select_catkin_workspace()
{
	if(check_catkin_workspace_exists $1 $2); then
		export SELECTED_CATKIN_WS="$1"
		return 0
	else
		return 1
	fi
}

function check_catkin_workspace_exists()
{
	catkin_dir="$HOME/ros/$2/$1"

	# check directory
	echo "Checking dir $catkin_dir"
	if [ ! -d "$catkin_dir" ]; then		
		return 1 
	else
		return 0
	fi

	echo
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


PARSED_OPTIONS=$(getopt -n "$0" -o c:r:l:s: --long "create-workspace:,ros-distro:,list-workspaces:,select-workspace"  -- "$@")

#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  exit 1
fi
 
# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

while true; do
	case "$1" in

		-c|--create-workspace)
			SELECTED_CATKIN_WS=$2
			shift 2;;

		-r|--ros-release)

			if(check_valid_ros_distro $2); then
				echo "Configuration scripts for ros $2 found"
				SELECTED_ROS_DISTRO=$2
			else
				echo "$(tput setaf 1)Configuration scripts for ros $2 not found$(tput sgr0)"
				exit
			fi

			shift 2;;

		-l|--list-workspaces)
		
			if(! list_catkin_workspaces $2); then
				echo "ros $2 has no catkin workspaces"
			fi
			
			exit;;

		-s|--select-workspaces)

			if(check_catkin_workspace_exists $2 $SELECTED_ROS_DISTRO); then
				export SELECTED_CATKIN_WS="$2"
				echo "Selected workspace $2 for ros $SELECTED_ROS_DISTRO"
			else
				echo "$(tput setaf 1)Error selecting workspace $2 for ros $SELECTED_ROS_DISTRO$(tput sgr0)"
			fi	
			exit;;

		--)

			shift
			break;;

	esac
done

if(check_catkin_workspace_exists $SELECTED_CATKIN_WS $SELECTED_ROS_DISTRO); then
	echo "ros catkin workspace '$SELECTED_CATKIN_WS' for ros $SELECTED_ROS_DISTRO already exists, skipping"
else

	CATKIN_DIR="$HOME/ros/$SELECTED_ROS_DISTRO/$SELECTED_CATKIN_WS"
	echo "Creating catkin workspace at: $CATKIN_DIR"
	source "$HOME/linux_config/general/ros_create_workspace.bash" $SELECTED_ROS_DISTRO $CATKIN_DIR
fi

		



