#!/bin/bash
set -eu -o pipefail

get_word() {
    echo $1 | awk -v N=$2 '{print $N}'
}

APP='auth-server'
IMAGE=$APP

docker-machine start                
eval $(docker-machine env)

if [[ $(docker images -a | grep $APP) ]]; then
    echo "Image \"$APP\" is already exist."
else
    docker build -t $APP .
fi

echo 'Starting container...'
docker run -it --rm --name $APP -p 3000:3000 $IMAGE
