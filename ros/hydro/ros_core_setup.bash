#!/bin/bash
# checking if ros setup bash script was run
ROS_DISTRO="hydro"
source "/opt/ros/$ROS_DISTRO/setup.bash"
export ROS_WORKSPACE="/opt/ros/$ROS_DISTRO/stacks"
echo "ROS $ROS_DISTRO is ready"


