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

function __catkin_eclipse_setup__()
{
  build_flag=$1
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi

  catkin build  --force-cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_flag
  __eclipse_project_files_gen__

}

function __eclipse_project_files_gen__()
{
  ROOT=$PWD 
  cd build
  for PROJECT in `find $PWD -name .project`; do
      DIR=`dirname $PROJECT`
      echo $DIR
      cd $DIR
      awk -f $(rospack find mk)/eclipse.awk .project > .project_with_env && mv .project_with_env .project
  done
  cd $ROOT
}

function __catkin_build__all__()
{
  build_flag=$1
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi
  options=$2
  catkin build --jobs 4 $options --cmake-args -DCMAKE_BUILD_TYPE=$build_flag
}

function __catkin_build__pkg__()
{
  build_flag=$2
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi
  pkg=$1
  options=$3  

  catkin build --jobs 4 $options $pkg --cmake-args -DCMAKE_BUILD_TYPE=$build_flag
}


### command alias list
alias catkin_gen_eclipse_project='__eclipse_project_files_gen__'
alias catkin_make_eclipse='__catkin_make_eclipse__'
alias catkin_build_eclipse='__catkin_eclipse_setup__'
alias cb='__catkin_build__all__'
alias cbpkg='__catkin_build__pkg__'


