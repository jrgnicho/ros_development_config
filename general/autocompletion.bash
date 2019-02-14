#!/bin/bash

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

_ros_session_()
{
  # creating list of workspaces
  local word=${COMP_WORDS[COMP_CWORD]}
  ros_distros=$(ls /opt/ros/)

  if [ $COMP_CWORD -eq 1 ]; then 
    # check for option    
    
    first_char=$(echo $word | cut -c1)
    if [ "$first_char" = "-" ]; then
      # using option so do nothing
      # TODO change this so that the option is entered after the ros distro name
      return
    fi
    COMPREPLY=($(compgen -W "${ros_distros}" ${word}))

    
  elif [ $COMP_CWORD -gt 1 ]; then
    local index=$(($COMP_CWORD-1))
    ros_distro=${COMP_WORDS[index]}
    workspaces=$(get_workspace_list ${ros_distro})
    COMPREPLY=($(compgen -W "${workspaces}" ${word}))
  fi

}

complete -F _ros_session_ ros_session
