#!/bin/bash
# checking if ros setup bash script was run
if [ -z "$ROS_PACKAGE_PATH" ]; then
	source "/opt/ros/$ROS_VER/setup.bash"
	export ROS_WORKSPACE="/opt/ros/$ROS_VER/stacks"
	echo "ROS $ROS_VER has been setup"
fi


