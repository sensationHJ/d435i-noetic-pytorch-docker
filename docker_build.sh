#!/bin/bash

DOCKER_BUILDKIT=1 docker build -t bombdetector:noetic .  --add-host="archive.ubuntu.com:$(dig +short jp.archive.ubuntu.com | tail -1)" 
## --no-cache
