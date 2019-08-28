#!/bin/bash

if [ $# -le 1 ]; then
  echo "invalid arguments, usage: 'docker_gui_run IMAGE_NAME CONTAINER_NAME'" >&2
  exit
fi

image_name="$1"
container_name="$2"

echo "creating docker container \"$container_name\" from image \"$image_name\""
docker run -dit --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --network=host \
  --name=$container_name \
  $image_name /bin/bash

xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $container_name`
echo "starting docker container"
docker start -i $container_name
