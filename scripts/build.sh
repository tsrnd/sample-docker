#!/bin/bash

set -exo pipefail

SECTION() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

clear

SECTION 'Build Images'

registry='192.168.99.100:5000'

create_machine() {
    local name="$1"
    log "create node '$name'"

    if docker-machine ls | grep "$name"; then
        if ! docker-machine ls | grep "$name" | grep "Running"; then
            docker-machine start "$name"
        fi
    else
        docker-machine create -d virtualbox \
            --virtualbox-boot2docker-url "file://$HOME/.docker/machine/1.12.5.iso" \
            --virtualbox-memory 1024 \
            --virtualbox-cpu-count 1 \
            --virtualbox-no-share \
            --virtualbox-no-vtx-check \
            --engine-insecure-registry $registry \
            "$name"
    fi
}

create_machine default
eval "$(docker-machine env default)"
if ! docker ps | grep 'registry:2'; then
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

SECTION 'Define'

app_name='chat'
app_dir='./chat'
app_image="$registry/$app_name:latest"

web_name='web'
web_dir='./web'
web_image="$registry/$web_name:latest"

SECTION 'Images'

log "build $app_image"
docker images | grep "$registry/$app_name" && docker rmi $app_image
docker build $app_dir -t $app_image
docker push $app_image

log "build $web_image"
docker images | grep "$registry/$web_name" && docker rmi $web_image
docker build $web_dir -t $web_image
docker push $web_image
