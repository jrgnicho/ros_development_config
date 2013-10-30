#!/bin/bash
# checking if ros setup bash script was run
if [ -z "$ROS_PACKAGE_PATH" ]; then
	source "/opt/ros/$ROS_DISTRO/setup.bash"
	export ROS_WORKSPACE="/opt/ros/$ROS_DISTRO/stacks"
	echo "ROS $ROS_DISTRO ready"
fi


