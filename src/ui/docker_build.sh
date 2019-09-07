#!/bin/bash
DateStr=$(date +"%Y-%m-%d %H:%M:%S")
#USER_NAME=ivbdockerhub

echo `git show --format="%h" HEAD | head -1` > build_info.txt
echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
echo "$DateStr docker_build script is running in ui" >> /tmp/make_info.log

docker build -t $USER_NAME/ui .

echo "$DateStr docker_build script completed building the $USER_NAME/ui" >> /tmp/make_info.log
