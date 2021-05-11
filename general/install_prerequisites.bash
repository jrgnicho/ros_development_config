#!/bin/bash

INSTALL_PACKAGES=("terminator")
REQUIRED_PACKAGES=("python-catkin-tools" "python3-colcon-common-extensions")

function check_debian()
{
  pkg=$1
  do_install=$2 #should be bool
  apt-cache show $pkg &> /dev/null
  if [ $? -eq 0 ] ; then
    echo "package \"$pkg\" was found" &> /dev/null 

    # check if it's installed
    dpkg -s $1 &> /dev/null  
    if [ $? -eq 1 ];
    then  
      
      if [ $do_install -eq 0 ] ; then
        echo "Required package \"$pkg\" not installed"
        return
      fi
          
      echo "Installing package \"$pkg\""
      sudo apt-get install $pkg 
    else
      echo "package \"$pkg\" is already installed" &> /dev/null
    fi      

  else
    echo "package $1 not found" >> /dev/stderr
    
  fi

}


function main()
{
  for pkg in ${INSTALL_PACKAGES[*]}
  do
    check_debian $pkg 1

  done
  
  for pkg in ${REQUIRED_PACKAGES[*]}
  do
    #echo "check debian package \"$pkg\" 0"
    check_debian $pkg 0

  done
}

main

