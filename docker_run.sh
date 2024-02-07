#!/bin/bash
xhost +
docker run --rm --net=host \
        --privileged --gpus all \
        -e DISPLAY=$DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v /etc/localtime:/etc/localtime:ro \
        -e TZ=Asia/Seoul \
        -v /dev:/dev \
        -it bombdetector:noetic \
        /bin/bash

## -v /dev:/dev : make docker read local usb in /dev/<USB_PATH>