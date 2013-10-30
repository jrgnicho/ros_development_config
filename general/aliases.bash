#!/bin/bash

# IPs List
ROBOT_WORKCELL_1_IP="000.000.00.000"
#BLUE_ROOM_2_IP="000.000.00.000"
#MANTIS_DEMO_2_IP="000.000.00.000"

# command alias list
alias cd_gradle_tutorials="cd ~/Desktop/Programming/Tutorials/gradle"
alias eclipse="~/Desktop/EclipseClassic_Kepler"
alias eclipse_cdt="~/Desktop/EclipseCdt_Indigo"

# ssh alias lists
arg="--tab-with-profile=BlueRoom2 --command='ssh -X jnicho@$ROBOT_WORKCELL_1_IP'"
alias ssh_robot_workcell_1="gnome-terminal $arg $arg $arg $arg $arg $arg $arg"

arg="--tab-with-profile=BlueRoom2 --command='ssh -X ros-industrial@$ROBOT_WORKCELL_1_IP'"
alias ssh_ros_industrial_1="gnome-terminal $arg $arg $arg $arg $arg $arg $arg"

#arg="--tab-with-profile=Mantis_Demo2 --command='ssh -X ros@$MANTIS_DEMO_2_IP'"
#alias ssh_mantis_demo_2="gnome-terminal $arg $arg $arg $arg $arg $arg $arg"
