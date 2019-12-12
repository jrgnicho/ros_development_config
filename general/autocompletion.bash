#!/bin/bash

function get_rosws_list()
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

function get_ros2ws_list()
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

_ros_session_()
{
  # creating list of workspaces
  local candidate_word=${COMP_WORDS[COMP_CWORD]}
  ros_distros=$(ls /opt/ros/)

  if [ $COMP_CWORD -eq 1 ]; then 
    # check for option    
    
    first_char=$(echo $candidate_word | cut -c1)
    if [ "$first_char" = "-" ]; then
      # using option so do nothing
      # TODO change this so that the option is entered after the ros distro name
      return        
    else
      COMPREPLY=($(compgen -W "${ros_distros}" ${candidate_word}))
    fi

    
  elif [ $COMP_CWORD -gt 1 ]; then
    
    local prev_index=$(($COMP_CWORD-1))
    local prev_entry=${COMP_WORDS[prev_index]}
    
    if [ "$prev_entry" = "-l" ]; then      
      COMPREPLY=($(compgen -W "${ros_distros}" ${candidate_word}))
      return 
    fi

    ros_distro=${prev_entry}
    workspaces=$(get_rosws_list ${ros_distro})
    COMPREPLY=($(compgen -W "${workspaces}" ${candidate_word}))
  fi

}

_ros2_session_()
{
  # creating list of workspaces
  local candidate_word=${COMP_WORDS[COMP_CWORD]}
  ros_distros=$(ls /opt/ros/)

  if [ $COMP_CWORD -eq 1 ]; then 
    # check for option    
    
    first_char=$(echo $candidate_word | cut -c1)
    if [ "$first_char" = "-" ]; then
      # using option so do nothing
      # TODO change this so that the option is entered after the ros distro name
      return        
    else
      COMPREPLY=($(compgen -W "${ros_distros}" ${candidate_word}))
    fi

    
  elif [ $COMP_CWORD -gt 1 ]; then
    
    local prev_index=$(($COMP_CWORD-1))
    local prev_entry=${COMP_WORDS[prev_index]}
    
    if [ "$prev_entry" = "-l" ]; then      
      COMPREPLY=($(compgen -W "${ros_distros}" ${candidate_word}))
      return 
    fi

    ros_distro=${prev_entry}
    workspaces=$(get_ros2ws_list ${ros_distro})
    COMPREPLY=($(compgen -W "${workspaces}" ${candidate_word}))
  fi

}

complete -F _ros_session_ ros_session
complete -F _ros2_session_ ros2_session
