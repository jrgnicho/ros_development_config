#!/bin/bash

# functions
############ DEPRECATED  ###################
function __catkin_make_eclipse__()
{
  build_flag=$1
  if [ -z "$build_flag" ]; then
    build_flag="Debug"
  fi

  catkin_make -DCMAKE_BUILD_TYPE=$build_flag --force-cmake -G"Eclipse CDT4 - Unix Makefiles" && awk -f $(rospack find mk)/eclipse.awk build/.project > build/.project_with_env && mv build/.project_with_env build/.project
}

############ DEPRECATED  ###################
function __catkin_build_eclipse__()
{

  if [ "$#" -eq 0 ]; then # build entire workspace
   
    catkin build --force-cmake -G"Eclipse CDT4 - Unix Makefiles"    
 
    # Lines below currrently break catkin due to some Unicode formatting issue ?
    #catkin build -c
    # __eclipse_ws_config__
  else
    for pkg in "$@"
    do

    catkin build --force-cmake -G"Eclipse CDT4 - Unix Makefiles" "$pkg"

    # Lines below currrently break catkin due to some Unicode formatting issue ?
    # catkin build -c "$pkg"
    # __eclipse_pkg_config__ $pkg
      
    done    
  fi
}

############ DEPRECATED  ###################
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

############ DEPRECATED  ###################
# generate project files for the entire workspace
function __eclipse_ws_config__() 
{
  current_dir=`pwd`

  packages=`catkin list | sed -e "s/- \(.*\)/\1/g"`
  for pkg_name in $packages; do
    echo "Started Eclipse setup for package \"$pkg_name\""
      __eclipse_pkg_config__ $pkg_name
  done
  cd "$current_dir"
}

############ DEPRECATED  ###################
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
  if [ ! -d "$src_dir" ]; then
    echo "-- Source directory $src_dir was not found, skipping package $pkg_name"
    return
  fi

  # finding other workspace directories
  install_dir=`catkin locate -i`
  devel_dir=`catkin locate -d`
  build_dir=`catkin locate -b`

  # enter project build directory
  pkg_build_dir="$build_dir/$pkg_name"
  # check that package build directory exists
  if [ ! -d "$pkg_build_dir" ]; then
    echo "-- Build directory $pkg_build_dir was not found, skipping package $pkg_name"
    return
  fi

  cd "$pkg_build_dir"

  cmake "$src_dir" -DCMAKE_INSTALL_PREFIX="$install_dir" -DCATKIN_DEVEL_PREFIX="$devel_dir" -G"Eclipse CDT4 - Unix Makefiles" &>/dev/null
  if [ $? -eq 0 ]; then
      echo "-- Created eclipse .project file for the '$pkg_name' package at location $pkg_build_dir"
  else
      echo "-- Failed to create eclipse .project for the '$pkg_name' package" 1>&2
  fi  

  # returning to previous directory
  cd "$current_dir"  
}

function __check_eclipsify__()
{
	rospack find eclipsify > /dev/null 2>&1
	
}

function __install_eclipsify__()
{
	rospack find eclipsify > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "eclipsify is already installed"
		return
	else
		echo "Installing eclipsify"
	fi

	# capture current path
	current_path=$(pwd)

	roscd src
	git clone https://github.com/ethz-asl/eclipsify
	roscd ws
	
	# moving active .rosinstall
	mkdir src/__temp__dir
	mv src/.rosinstall src/__temp__dir/.rosinstall > /dev/null 2>&1
	mv src/.rosinstall.bak src/__temp__dir/.rosinstall.bak > /dev/null 2>&1
	
	wstool init src
	wstool merge -t src src/eclipsify/.rosinstall
	wstool update -t src
	catkin build eclipsify
	
	#installing python dependencies
	pip install --user termcolor

	# reinstating active .rosinstall
	rm src/.rosinstall
	rm src/.rosinstall.bak
	mv src/__temp__dir/.rosinstall src/.rosinstall > /dev/null 2>&1
	mv src/__temp__dir/.rosinstall.bak src/.rosinstall.bak > /dev/null 2>&1
	rm -r src/__temp__dir/

	# sourcing the workspace
	source devel/setup.bash

	# return to current path
	cd $current_path
}

function __create_eclipse_projects__()
{
	rospack find eclipsify > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "eclipsify is not installed run: \"install_eclipsify\""
		return
	fi
	roscd ws
	mkdir projects > /dev/null 2>&1
	catkin list -u | xargs -I pkg eclipsify pkg -O projects/pkg
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
alias install_eclipsify='__install_eclipsify__'
alias create_eclipse_projects='__create_eclipse_projects__'
alias cb='__catkin_build__all__'
alias cbpkg='__catkin_build__pkg__' 
