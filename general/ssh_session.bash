#!/bin/bash

IP=""
USER=""
PROFILE="Default"
TERMINAL_CMD="mate-terminal"


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


# concatenate inputs
FULL_ID="$USER@$IP"

# construct command
TERMINAL_TAB_ARGS="--title='$USER:ssh_session' --profile=$PROFILE --command='ssh -X $FULL_ID'"
NEW_TAB_ARG="--tab $TERMINAL_TAB_ARGS"
COMMAND="$TERMINAL_CMD --window $TERMINAL_TAB_ARGS $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG"

eval $COMMAND
