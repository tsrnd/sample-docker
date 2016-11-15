#!/bin/bash
set -eux -o pipefail

get_word() {
    echo "$1" | awk -v N="$2" '{print $N}'
}

APP='auth-server'
IMAGE=$APP
CONTAINER=$APP

docker-machine start || true    
echo 'Export machines environment.'            
eval $(docker-machine env)

echo 'Remove old container.'
if [[ $(docker ps -a | grep $CONTAINER) ]]; then
    LINE="$(docker ps -a | grep $CONTAINER)"
    CONTAINER_ID=$(get_word "$LINE" 1)
    docker rm -f $CONTAINER_ID
fi

echo 'Remove old image.'
if [[ $(docker images -a | grep $IMAGE) ]]; then
    LINE="$(docker images -a | grep $IMAGE)"
    IMAGE_ID=$(get_word "$LINE" 3)
    docker rmi $IMAGE_ID 
fi
echo 'Build image...'
docker build -t $IMAGE .

echo 'Start container...'
docker run -i -t -d --name $APP -p 3000:3000 $IMAGE

docker ps
