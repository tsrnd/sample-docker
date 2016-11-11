#!/bin/bash

CONTAINER="$(docker ps -a | grep auth-server)"
N=1
CONTAINER_ID=$(echo $CONTAINER | awk -v N=$N '{print $N}')
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

IMAGE="$(docker images -a | grep auth-server)"
N=3
IMAGE_ID=$(echo $IMAGE | awk -v N=$N '{print $N}')
docker rmi $IMAGE_ID

echo ''
docker ps -a
echo ''
docker images -a
