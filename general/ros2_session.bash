#!/bin/bash

ROS2_DISTRO=""
PROFILE="Default"
ROS2_WS="ros2_ws"
ROS_SYSTEM_PATH="/opt/ros"
CUSTOM_WS_SETUP_SCRIPT="env.bash"
CREATE_NEW_WS=false
TEMP_BASH_FILE="bashrc_ros2.tmp"
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

function check_colcon()
{
  
  pkg="python3-colcon-common-extensions"
  echo "Check for package $pkg"
  colcon --help >/dev/null
  if [ $? -eq 0 ] ; then
    echo "colcon was found"  
  else
    return 1    
  fi
}

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

        # check colcon 
        check_colcon
        if [ $? -ne 0 ]; then
          echo "$(tput setaf 1)Colcon is not installed, check https://colcon.readthedocs.io/en/released/user/installation.html $(tput sgr0)"
          exit 1
        fi
        
	      # checking that required variables have been set
	      if [ "$ROS2_DISTRO" == "" ] ; then
	        echo "$(tput setaf 1)ROS distribution has not been set; recommended use:$(tput sgr0)"
	        echo "$(tput setaf 1)ros2_session -c [ros2-distro] [ros2_ws]:$(tput sgr0)"
	        exit 1
	      fi
	
	      # workspace creation
	      source "$HOME/ros_development_config/general/ros2_create_ws.bash" $ROS2_DISTRO $ROS2_WS $SELECTED_BUILD_TOOL
        if [ $? -ne 0 ]; then
          echo "$(tput setaf 1)Failed to create colcon workspace $(tput sgr0)"
          exit 1
        fi
	      
	    else
			  echo "$(tput setaf 1)ROS2 workspace $ROS2_WS for ros $ROS2_DISTRO was not found$(tput sgr0)"
			  exit 1
	    fi
  	fi

  ############### Checking prerequisites ######################
  ROS2WS_DIR="$HOME/ros2/$ROS2_DISTRO/$ROS2_WS"
  WS_SETUP_SCRIPT="$ROS2WS_DIR/install/setup.bash"

  if ! [ -f "$WS_SETUP_SCRIPT" ]; then
	  echo "$(tput setaf 1)Error sourcing the ros2 workspace setup script $WS_SETUP_SCRIPT$(tput sgr0)"
    exit 1
  fi

  # check directory for custom distribution level configuration script
  CUSTOM_DISTRO_SETUP_SCRIPT="$HOME/ros2/$ROS2_DISTRO/setup.bash"
  if ! [ -f "$CUSTOM_DISTRO_SETUP_SCRIPT" ]; then
	  echo "$(tput setaf 3)Custom distro script $CUSTOM_DISTRO_SETUP_SCRIPT was not found, creating default one$(tput sgr0)"
    echo "#!/bin/bash" > $CUSTOM_DISTRO_SETUP_SCRIPT
    echo "####### WARNING - DO NOT DELETE THIS ######" >> $CUSTOM_DISTRO_SETUP_SCRIPT
  fi

  # check if custom worspace level setup script exists
  CUSTOM_WS_SETUP_SCRIPT_PATH="$ROS2WS_DIR/$CUSTOM_WS_SETUP_SCRIPT"
  if ! [ -f "$CUSTOM_WS_SETUP_SCRIPT_PATH" ]; then
	  echo "$(tput setaf 3)Creating workspace setup script $CUSTOM_WS_SETUP_SCRIPT_PATH$(tput sgr0)"
    echo "#!/bin/bash" > $CUSTOM_WS_SETUP_SCRIPT_PATH
    echo "source $CUSTOM_DISTRO_SETUP_SCRIPT" >> $CUSTOM_WS_SETUP_SCRIPT_PATH
    echo "source $WS_SETUP_SCRIPT" >> $CUSTOM_WS_SETUP_SCRIPT_PATH
  fi
	
	###############  launch terminals ###############   
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
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/$TEMP_BASH_FILE
	echo "source $LINUX_CONF_PATH/general/ros2_env_setup.bash $ROS2_DISTRO $ROS2_WS">>"$LINUX_CONF_PATH/$TEMP_BASH_FILE"
  echo "echo -e \"\033]0;ROS2-$ROS2_DISTRO [$ROS2_WS]\007\"">>"$LINUX_CONF_PATH/$TEMP_BASH_FILE" # set title
	COMMAND="$TERMINAL_CMD -g $LINUX_CONF_PATH/general/terminator_config -l ros2_devel"
	# the terminator configuration file has been set to execute the "bashrc.temp" script on each new terminal
	eval $COMMAND & >> /dev/null
	return 0
}

function launch_mate_terminal()
{
	TERMINAL_CMD="mate-terminal"
	# construct bash file
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/$TEMP_BASH_FILE
	echo "source $LINUX_CONF_PATH/general/ros2_env_setup.bash $ROS2_DISTRO $ROS2_WS">>"$LINUX_CONF_PATH/$TEMP_BASH_FILE"
  TERMINAL_TAB_ARGS="--title='ros-$ROS2_DISTRO: $ROS2_WS' --profile=$PROFILE --command='bash --rcfile $LINUX_CONF_PATH/$TEMP_BASH_FILE'"
	NEW_TAB_ARG="--tab $TERMINAL_TAB_ARGS"
	COMMAND="$TERMINAL_CMD --window $TERMINAL_TAB_ARGS $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG"

	eval $COMMAND &
	return 0
}

main "$@"
