#!/bin/bash

############## Android sdk paths ##########################
export PATH=$PATH:/home/coky/android-sdk/tools:/home/coky/android-sdk/platform-tools
export ANDROID_SDK_HOME=/home/coky/android-sdk

############## Android ROS paths ##########################
#export ANDROID_ROS_LIB_PATH=/home/coky/ROS/android_ros/$ROS_VER
#export ANDROID_ROS_LIB_PATH=/home/coky/ROS/android_ros/fuerte

############## Android ROS setup script ##########################
#source $ANDROID_ROS_LIB_PATH/setup.bash

############## ROS_PACKAGE_PATH Setup ##########################
# path setup for android and projects
#export ROS_PACKAGE_PATH=$ANDROID_ROS_LIB_PATH:$ROS_PACKAGE_PATH

############## Gradlew build system setup ##########################
#alias gradlew="bash /home/coky/ROS/android_ros/"$ROS_VER"/android_core/gradlew"
#alias gradlew="bash /home/coky/ROS/android_ros/fuerte/android_core/gradlew"


