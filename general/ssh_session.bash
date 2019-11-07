#!/bin/bash

IP=""
USER=""
PROFILE="ssh"


function launch_mate_terminal()
{
  # concatenate inputs
  FULL_ID="$USER@$IP"
  TERMINAL_CMD="mate-terminal"

  # construct command
  TERMINAL_TAB_ARGS="--title='$USER:ssh_session' --profile=$1 --command='ssh -X $FULL_ID'"
  NEW_TAB_ARG="--tab $TERMINAL_TAB_ARGS"
  COMMAND="$TERMINAL_CMD --window $TERMINAL_TAB_ARGS $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG"

  eval $COMMAND
  return 0
}

function launch_terminator_terminal()
{
  #TODO custom profile cannot be enforced on a layout
  FULL_ID="$USER@$IP"
	TERMINAL_CMD="terminator"
  SSH_COMMAND="ssh -X $FULL_ID"
  cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
  #echo  "setterm --term linux --background yellow --foreground black --clear all --half-bright off" >>"$LINUX_CONF_PATH/bashrc.tmp"
  echo  "$SSH_COMMAND" >>"$LINUX_CONF_PATH/bashrc.tmp"
	COMMAND="$TERMINAL_CMD -g $LINUX_CONF_PATH/general/terminator_config -l ros_devel --title=ssh:$FULL_ID "
	# the terminator configuration file has been set to execute the "bashrc.temp" script on each new terminal
	eval $COMMAND & >> /dev/null
	return 0
}

# check arguments
if [[ ( "$#" -lt 2 )]]; then
	echo "must pass user name and ip as follows: ssh_session.bash username ipaddress"
	exit
else
	IP=$2
	USER=$1
fi 

if [[ ( "$#" -ge 3 )]]; then
	PROFILE=$3
fi

#launch_mate_terminal $PROFILE
launch_terminator_terminal $PROFILE

