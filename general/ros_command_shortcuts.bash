#!/bin/bash

# command alias list

# Builds project file for the Eclipse CDT IDE
alias catkin_make_eclipse='catkin_make -DCMAKE_BUILD_TYPE=Debug --force-cmake -G"Eclipse CDT4 - Unix Makefiles" && awk -f $(rospack find mk)/eclipse.awk build/.project > build/.project_with_env && mv build/.project_with_env build/.project'


