#!/bin/bash

# functions
function __catkin_make_eclipse__()
{
  build_flag=$1
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi

  catkin_make -DCMAKE_BUILD_TYPE=$build_flag --force-cmake -G"Eclipse CDT4 - Unix Makefiles" && awk -f $(rospack find mk)/eclipse.awk build/.project > build/.project_with_env && mv build/.project_with_env build/.project
}


### command alias list
alias catkin_make_eclipse='__catkin_make_eclipse__'


