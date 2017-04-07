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
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi 

  

  if [ "$#" -eq 0 ]; then # build entire workspace
   catkin build -c --force-cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_flag
    __eclipse_project_files_gen__
  else

    for pkg in "$@"
    do
      catkin build "$pkg" -c --force-cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=$build_flag

      # entering package build dir
      build_dir=`catkin locate -b`
      pkg_build_dir="$build_dir/$pkg"
      cd "$pkg_build_dir"

      # copying template into package build directory
      echo "Creating eclipse project file at $pkg_build_dir"
      awk -f $(rospack find mk)/eclipse.awk .project > .project_with_env && mv .project_with_env .project

      # returning to workspace
      cd "$build_dir/.."
      
    done
    
  fi
  

}

# generate project files for the entire workspace
function __eclipse_project_files_gen__() 
{
  build_dir=`catkin locate -b`
  cd "$build_dir"
  for PROJECT in `find $PWD -name .project`; do
      DIR=`dirname $PROJECT`
      echo $DIR
      cd $DIR
      awk -f $(rospack find mk)/eclipse.awk .project > .project_with_env && mv .project_with_env .project
  done
  cd "$build_dir/.."
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
alias catkin_build_eclipse='__catkin_build_eclipse__'
alias cb='__catkin_build__all__'
alias cbpkg='__catkin_build__pkg__'


