# Docker For D435i + pytorch + ros noetic !
no one made exact docker iamge for this so... I make it ! haha

In order to use CUDA in librealsense, I built it myself, not using apt-get install.

## ENV
* Realsense D435i 
* Ubuntu 20.04 + ros noetic
* python 3.8.13 (basic)
* torch 1.13.0,  CUDA 11.7

## How to?
### build
```bash
sh docker_build.sh
```

### run
after connect D435I,
```bash
sh docker_run.sh
## after enter into docker
sh launch_cam.sh
```

if you want to see what images are running, open another terminal and

```bash
docker ps 
## you can copy <Container ID>
docker exec -it <Container ID> /bin/bash
rviz
```
you can use rviz to see the images

