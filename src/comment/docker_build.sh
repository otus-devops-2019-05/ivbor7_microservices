#!/bin/bash
DateStr=$(date +"%Y-%m-%d %H:%M:%S")
USER_NAME=ivbdockerhub

echo `git show --format="%h" HEAD | head -1` > build_info.txt
echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
echo "$DateStr docker_build script is running in comment for $USER_NAME Registry" >> /tmp/make_info.log

docker build -t $USER_NAME/comment .

echo "$DateStr docker_build script completed building $USER_NAME/comment" >> /tmp/make_info.log
