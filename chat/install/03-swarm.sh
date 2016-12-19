#!/bin/bash

APP=chat-app
APP_DIR=./app
APP_IMAGE=$APP:0.0.0
DB=chat-db
DB_DIR=./data
DB_IMAGE=$DB:0.0.0
NET_LOCAL=chat-local
NET_PUBLIC=chat-public
NET_PORT=2377
PROXY=chat-proxy
PROXY_DIR=./proxy
PROXY_IMAGE=$PROXY:0.0.0

# build images
docker-machine create -d virtualbox default \
    || docker-machine start default
eval $(docker-machine env default)
docker build $APP_DIR -t $APP_IMAGE
docker build $DB_DIR -t $DB_IMAGE
docker build $PROXY_DIR -t $PROXY_IMAGE

# create nodes
for i in 01 02 03; do
    docker-machine create -d virtualbox "node$i" \
        || docker-machine start "node$i"
done

# init swarm with node01
TOKEN=''

# add other nodes to swarm
for i in 01 02 03; do
    eval $(docker-machine env "node$i")
    if [[ $i == '01' ]]; then
        docker swarm init \
            --advertise-addr $(docker-machine ip node01) \
            --listen-addr $(docker-machine ip node01):$NET_PORT
        TOKEN=$(docker swarm join-token -q worker)
    else
        docker swarm join \
            --token $TOKEN \
            $(docker-machine ip node01):$NET_PORT
    fi
done

# create network layers
eval $(docker-machine env node01)
docker network create --driver overlay $NET_PUBLIC
docker network create --driver overlay $NET_LOCAL

# create service layers
docker service create --name $DB \
    --network $NET_LOCAL \
    $DB_IMAGE
docker service create --name $APP \
    -e DB=$DB \
    --network $NET_LOCAL \
    --network $NET_PUBLIC \
    $APP_IMAGE

docker service create --name $PROXY \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    --network $NET_PUBLIC \
    -e MODE=swarm \
    $PROXY_IMAGE
docker service ps $PROXY
