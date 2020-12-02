#!/bin/bash


function main()
{

  if [ "$#" -ne 1 ]; then
     echo "You must enter the package name"
     exit 1
  fi  
  
  # check package
  pkg=$1
  eval "rospack find $pkg"
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "The package $pkg was not found"
    exit 1
  fi

  # going to root ws directory
  current_dir=${PWD}
  eval "roscd ws"
  
  # calling build cmd with correct argument
  cmd="catkin build --no-deps $pkg --force-cmake -G\"Eclipse CDT4 - Unix Makefiles\""
  eval $cmd
  if [ $RESULT -ne 0 ]; then
    echo "The command $build_cmd failed"
    exit 1
  fi

  # modifying .project file
  build_dir=`catkin locate --build`
  cmd="awk -f $(rospack find mk)/eclipse.awk $build_dir/$pkg/.project > $build_dir/$pkg/.project_mod"
  eval $cmd
  if [ $RESULT -ne 0 ]; then
    echo "The command $cmd failed"
    exit 1
  fi

  # creating project directory
  project_dir="$build_dir/../projects/$pkg"
  cmd="mkdir -p $project_dir && mv $build_dir/$pkg/.project_mod $project_dir/.project && mv $build_dir/$pkg/.cproject $project_dir/.cproject"
  eval $cmd
  if [ $RESULT -ne 0 ]; then
    echo "The command $cmd failed"
    exit 1
  fi

  # cleanup files 
  cmd="rm $build_dir/$pkg/.project"
  eval $cmd

  # return to current directory
  cd $current_dir

  echo "created project files for package $pkg in the projects directory"
}

main "$@"
