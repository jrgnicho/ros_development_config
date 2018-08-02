#!/bin/bash

REQUIRED_PACKAGES=("terminator" "python-catkin-tools")

function check_debian()
{
  pkg=$1
  apt-cache show $pkg &> /dev/null
  if [ $? -eq 0 ] ; then
    echo "package \"$pkg\" was found" &> /dev/null 

    # check if it's installed
    dpkg -s $1 &> /dev/null  
    if [ $? -eq 1 ];
    then      
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
  for pkg in ${REQUIRED_PACKAGES[*]}
  do
	  #echo "check debian package \"$pkg\""
    check_debian $pkg

  done
}

main

