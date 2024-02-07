FROM nvcr.io/nvidia/pytorch:22.07-py3
### references ###
# https://github.com/iory/docker-ros-realsense, 
# https://github.com/MojaX2/docker-ros-noetic/blob/master/Dockerfile
# https://github.com/thecanadianroot/opencv-cuda-docker/blob/main/Dockerfile.ros-noetic

LABEL maintainer="hjj@hancomspace.com"

## Enable Nvidia gpu
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

## gook bob setting
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt -q -qq update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    software-properties-common \
    wget \
    apt-transport-https \
    git \
    build-essential \
    cmake

## to run pytorch
RUN apt-get install -y libopenblas-base libopenmpi-dev

## Setup realsense library
RUN apt-get install -y libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev
RUN apt-get install -y libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev curl 
RUN git clone https://github.com/IntelRealSense/librealsense.git /librealsense
RUN mkdir /librealsense/build
WORKDIR /librealsense/build
RUN cmake /librealsense -DCMAKE_BUILD_TYPE=Release -DBUILD_WITH_CUDA=true
RUN make uninstall && make clean
RUN time make -j8 && make install
WORKDIR /

## No build version
# RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
# RUN add-apt-repository -y "deb https://librealsense.intel.com/Debian/apt-repo focal main"
# RUN apt-get update -qq
# RUN apt-get install librealsense2-dkms --allow-unauthenticated -y
# RUN apt-get install librealsense2-dev --allow-unauthenticated -y
# RUN apt-get install  -y

## ROS noetic INSTALL
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO noetic

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop-full 

RUN apt -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt install -y --allow-unauthenticated \
  python3-catkin-tools \
  python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool python3-catkin-pkg \
  ros-${ROS_DISTRO}-jsk-tools \
  ros-${ROS_DISTRO}-rgbd-launch \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-image-transport \
  ros-${ROS_DISTRO}-rqt* 


RUN rosdep init
RUN rosdep update

## Build realsense-ros pkg 
# RUN apt install -y python3-empy 
RUN pip uninstall em
RUN pip install empy==3.3.4 catkin_pkg 
RUN mkdir -p /catkin_ws/src && cd /catkin_ws/src && \
  git clone -b ros1-legacy --depth 1 https://github.com/IntelRealSense/realsense-ros.git && \
  git clone -b kinetic-devel --depth 1 https://github.com/pal-robotics/ddynamic_reconfigure

WORKDIR /catkin_ws
RUN rosdep install --from-paths src --ignore-src -r -y
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source /opt/ros/${ROS_DISTRO}/setup.bash;  catkin build -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release
RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh

## setup ROS
RUN touch /root/.bashrc && \
  echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
  echo "source /catkin_ws/devel/setup.bash" >> /root/.bashrc && \
  echo "rossetip" >> /root/.bashrc && \
  echo "rossetmaster localhost"

# remove update list to reduce docker image volume
RUN rm -rf /var/lib/apt/lists/*

COPY ./launch_cam.sh /catkin_ws/ 
# WORKDIR /catkin_ws

CMD ["bash"]