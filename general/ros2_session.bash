#!/bin/bash

ROS2_DISTRO=""
PROFILE="Default"
ROS2_WS="ros2_ws"
ROS_SYSTEM_PATH="/opt/ros"
CREATE_NEW_WS=false
BUILD_TOOLS=("colcon")
SELECTED_BUILD_TOOL="${BUILD_TOOLS[0]}"
TERMINAL_OPTIONS=("terminator" "mate-terminal")
TERMINAL_SELECTION="${TERMINAL_OPTIONS[0]}"

SHORT_OPTIONS="r:w:l:p:c::h"
LONG_OPTIONS="ros2-distro:,workspace:,list-workspaces:,profile:,create::,help"
HELP_TEXT="Usage:\n
-r|--ros2-distro [ros2-distro] -w|--workspace [workspace name]\n
-l|--list-workspaces [ros2-distro]\n
-c|--ros2-distro [ros2-distro] -w|--workspace [workspace name] --create\n
-h|--help \n"

function select_build_tool()
{
  for var in "${BUILD_TOOLS[@]}"
  do

    if [ "$var" == "$1" ]
    then
      SELECTED_BUILD_TOOL=$1
      echo "Selected build tool '${SELECTED_BUILD_TOOL}'"
      return 
    fi
  done

  echo "Selected default build tool '${SELECTED_BUILD_TOOL}'"
  return
}

function check_supported_ros_distro()
{
	ros_distro=$1
	
	# check directory
	if [ ! -d "$ROS_SYSTEM_PATH/$ros_distro" ]; then		
		return 1 
	else
		return 0
	fi
}

function check_ros2_workspace_exists()
{
	ros2_dir="$HOME/ros2/$2/$1"

	# check directory
	if [ ! -d "$ros2_dir" ]; then		
		return 1 
	else
		return 0
	fi
}

function get_workspace_list()
{
	ros_distro=$1
	ros_dir="$HOME/ros2/$1"
	local -a a=()

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return
	fi

	# iterating through directories
	counter=0
	for d in $(ls -d $ros_dir/*); do
		ros2_ws=$(basename $d)

		# add ws to array
		a[$counter]=$ros2_ws
		let counter=counter+1

	done

	echo ${a[@]}
}

function list_ros2_workspaces()
{
	ros_distro=$1
	ros_dir="$HOME/ros2/$1"

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return 1
	fi

	declare -a a=()
	a=$(get_workspace_list $ros_distro)

	for i in ${a[@]}; do
		echo "$i"
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
			-r|--ros2-distro)
				#echo "ros2-distro selected $OPTARG"
				ROS2_DISTRO=$OPTARG
				shift 2
				;;

			-w|--workspace)
				#echo "ros2 workspace selected $OPTARG"
				ROS2_WS=$OPTARG
				shift 2
				;;

			-l|--list-workspaces)

        ROS2_DISTRO=$OPTARG        
				if(! list_ros2_workspaces $ROS2_DISTRO); then
					echo "ros $2 has no ros2 workspaces"
					exit 1
				else
					exit 0
				fi
				;;

			-h|--help)
				echo -e $HELP_TEXT
				exit 0
				;;

			-p|--profile)

				PROFILE=$OPTARG
				shift 2
				;;

      -c| --create)

        CREATE_NEW_WS=true
        select_build_tool $OPTARG
        if [[ -z "$OPTARG" ]]; then
          shift 1
        else
          shift 2
        fi

        ;;

			--)
				# finished parsing options
				break;;

      *)
        #echo "no valid entry, shifting 1"
        shift 1
        ;;


		esac
	
		let OPTIND=OPTIND+1
	done

	# positional arg ros2-distro
	if [ $# -ge 2 ]; then
		ROS2_DISTRO=$2
	fi

	# positional arg workspace
	if [ $# -ge 3 ]; then
		ROS2_WS=$3
	fi

		# positional arg profile
	if [ $# -ge 4 ]; then
		PROFILE=$4
	fi

	# check ros distro
	if (! check_supported_ros_distro $ROS2_DISTRO); then
		echo "$(tput setaf 1)ROS2 Distribution '$ROS2_DISTRO' was not found$(tput sgr0)"
		exit 1
	fi

	if (! check_ros2_workspace_exists $ROS2_WS $ROS2_DISTRO); then
	    if $CREATE_NEW_WS ; then	
	      # checking that required variables have been set
	      if [ "$ROS2_DISTRO" == "" ] ; then
	        echo "$(tput setaf 1)ROS distribution has not been set; recommended use:$(tput sgr0)"
	        echo "$(tput setaf 1)ros2_session -c [ros2-distro] [ros2_ws]:$(tput sgr0)"
	        exit 1
	      fi
	
	      # workspace creation
	      source "$HOME/ros_development_config/general/ros2_create_ws.bash" $ROS2_DISTRO $ROS2_WS $SELECTED_BUILD_TOOL
	      
	    else
			  echo "$(tput setaf 1)ROS2 workspace $ROS2_WS for ros $ROS2_DISTRO was not found$(tput sgr0)"
			  exit 1
	    fi
  	fi
	
	# launch terminals
	if [ "$TERMINAL_SELECTION" == "${TERMINAL_OPTIONS[0]}" ]; then
		launch_terminator_terminal
	elif [ "$TERMINAL_SELECTION" == "${TERMINAL_OPTIONS[1]}" ]; then
		launch_mate_terminal
	else
		launch_terminator_terminal
	fi
	
}

function launch_terminator_terminal()
{
	TERMINAL_CMD="terminator"
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
	echo "source $LINUX_CONF_PATH/general/ros2_env_setup.bash $ROS2_DISTRO $ROS2_WS">>"$LINUX_CONF_PATH/bashrc.tmp"
	echo "echo -e \"\033]0;ROS-$ROS2_DISTRO [$ROS2_WS]\007\"">>"$LINUX_CONF_PATH/bashrc.tmp" # set title
	echo "export PS1=\"ROS-$ROS2_DISTRO[$ROS2_WS]: \"&& clear">>"$LINUX_CONF_PATH/bashrc.tmp"
	echo "echo \"$(tput setaf 3)ROS2 workspace [$ROS2_WS] is ready$(tput sgr0)\"">>"$LINUX_CONF_PATH/bashrc.tmp"
	COMMAND="$TERMINAL_CMD -g $LINUX_CONF_PATH/general/terminator_config -l ros_devel"
	# the terminator configuration file has been set to execute the "bashrc.temp" script on each new terminal
	eval $COMMAND & >> /dev/null
	return 0
}

function launch_mate_terminal()
{
	TERMINAL_CMD="mate-terminal"
	# construct bash file
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
	echo "source $LINUX_CONF_PATH/general/ros_core_setup.bash $ROS2_DISTRO $ROS2_WS">>"$LINUX_CONF_PATH/bashrc.tmp"
  TERMINAL_TAB_ARGS="--title='ros-$ROS2_DISTRO: $ROS2_WS' --profile=$PROFILE --command='bash --rcfile $LINUX_CONF_PATH/bashrc.tmp'"
	NEW_TAB_ARG="--tab $TERMINAL_TAB_ARGS"
	COMMAND="$TERMINAL_CMD --window $TERMINAL_TAB_ARGS $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG"

	eval $COMMAND &
	return 0
}

main "$@"
