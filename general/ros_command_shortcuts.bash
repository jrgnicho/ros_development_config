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

function __catkin_build_eclipse__()
{
  build_flag=$1

  # setting build flag
  if [ -z "$build_flag" ]; then
    build_flag="Debug"  # defaults to Debug if none was passed
  fi 
  

  if [ "$#" -eq 0 ]; then # build entire workspace
   catkin build -c --cmake-args -DCMAKE_BUILD_TYPE=$build_flag
    __eclipse_ws_config__
  else
    for pkg in "$@"
    do

      catkin build -c "$pkg" --cmake-args -DCMAKE_BUILD_TYPE=$build_flag
      __eclipse_pkg_config__ $pkg
      
    done    
  fi
}

function __catkin_config_eclipse__()
{
  if [ "$#" -eq 0 ]; then # no specific packages then configure entire workspace
    __eclipse_ws_config__
  else
  
    for pkg in "$@"
    do
      __eclipse_pkg_config__ $pkg
    done
    
  fi
}

# generate project files for the entire workspace
function __eclipse_ws_config__() 
{
  current_dir=`pwd`
  build_dir=`catkin locate -b`

  for eclipse_proj_path in `find $build_dir -name .project`; do
      DIR=`dirname $eclipse_proj_path`
      pkg_name=`dirname $eclipse_proj_path | xargs -n 1 basename`

      __eclipse_pkg_config__ $pkg_name
  done
  cd "$current_dir"
}

# generate .project files for a single package
function __eclipse_pkg_config__()
{
  if [ "$#" -eq 0 ]; then
    echo "No project name was passed, can't create eclipse .project file" 1>&2
    return
  fi 

  pkg_name=$1
  current_dir=`pwd` # storing current directory
  src_dir=`catkin locate $pkg_name`

  # check that src directory exists
  if [ -z "$src_dir" ]; then
    return
  fi

  # finding other workspace directories
  install_dir=`catkin locate -i`
  devel_dir=`catkin locate -d`
  build_dir=`catkin locate -b`

  # enter project build directory
  pkg_build_dir="$build_dir/$pkg_name"
  cd "$pkg_build_dir"

  cmake "$src_dir" -DCMAKE_INSTALL_PREFIX="$install_dir" -DCATKIN_DEVEL_PREFIX="$devel_dir" -G"Eclipse CDT4 - Unix Makefiles" &>/dev/null
  if [ $? -eq 0 ]; then
      echo "-- Created eclipse .project file for the '$pkg_name' package at location $pkg_build_dir"
  else
      echo "Failed to create eclipse .project for the '$pkg_name' package" 1>&2
  fi  

  # returning to previous directory
  cd "$current_dir"  
}

function __catkin_build__all__()
{
  build_flag=$1
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi
  options=$2
  catkin build --jobs 2 $options --cmake-args -DCMAKE_BUILD_TYPE=$build_flag
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
alias catkin_config_eclipse='__catkin_config_eclipse__'
alias catkin_make_eclipse='__catkin_make_eclipse__'
alias catkin_build_eclipse='__catkin_build_eclipse__'
alias cb='__catkin_build__all__'
alias cbpkg='__catkin_build__pkg__' 
