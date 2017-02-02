#!/bin/bash

set -eo pipefail

section() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

clear

section 'Build Images'

create_machine() {
    local MACHINE_NAME="$1"
    log "create node '$MACHINE_NAME'"

    if docker-machine ls | grep "$MACHINE_NAME"; then
        if ! docker-machine ls | grep "$MACHINE_NAME" | grep "Running"; then
            docker-machine start "$MACHINE_NAME"
        fi
    else
        docker-machine create -d virtualbox \
            --virtualbox-memory 1024 \
            --virtualbox-cpu-count 1 \
            --virtualbox-no-share \
            --virtualbox-no-vtx-check \
            "$MACHINE_NAME"
    fi
}

section 'Prepare'

REGISTRY_MACHINE='registry'
create_machine "$REGISTRY_MACHINE"
eval "$(docker-machine env $REGISTRY_MACHINE)"
REGISTRY="$(docker-machine ip $REGISTRY_MACHINE):5000"

if ! docker ps -a | grep 'registry:2'; then
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

section 'Define'

APP_NAME='chat'
APP_DIR='./chat'
APP_IMAGE="$REGISTRY/$APP_NAME:latest"

WEB_NAME='web'
WEB_DIR='./web'
WEB_IMAGE="$REGISTRY/$WEB_NAME:latest"

section 'Images'

log "build $APP_IMAGE"
docker images | grep "$REGISTRY/$APP_NAME" && docker rmi "$APP_IMAGE"
docker build "$APP_DIR" -t "$APP_IMAGE"
docker push "$APP_IMAGE"

log "build $WEB_IMAGE"
docker images | grep "$REGISTRY/$WEB_NAME" && docker rmi "$WEB_IMAGE"
docker build "$WEB_DIR" -t "$WEB_IMAGE"
docker push "$WEB_IMAGE"
