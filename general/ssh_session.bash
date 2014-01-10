#!/bin/bash

IP=""
USER=""
PROFILE="Default"


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
ARG="--tab-with-profile=$PROFILE --command='ssh -X $FULL_ID'"
COMMAND="gnome-terminal $ARG $ARG $ARG $ARG $ARG $ARG $ARG"

eval $COMMAND
