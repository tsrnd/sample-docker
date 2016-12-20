#!/bin/bash

set -e -o pipefail

REGISTRY='172.16.110.141:5000'
MACHINE_FLAGS="-d virtualbox
    --virtualbox-boot2docker-url file://$HOME/.docker/machine/iso/default.iso
    --virtualbox-memory 1024
    --virtualbox-cpu-count 1
    --virtualbox-no-share
    --virtualbox-no-vtx-check
    --engine-insecure-registry $REGISTRY"

NODE='node-chat'
APP='app-chat'
APP_DIR=./app/chat
APP_IMAGE="$REGISTRY/$APP:0.0.0"
DB='data-redis'
DB_DIR=./data/redis
DB_IMAGE="$REGISTRY/$DB:0.0.0"
NET_LOCAL=net-local
NET_PUBLIC=net-public
NET_PORT=2377
PROXY=proxy
PROXY_DIR=./proxy
PROXY_IMAGE="$REGISTRY/$PROXY:0.0.0"

# build images
docker-machine create $MACHINE_FLAGS default \
    || docker-machine start default \
    || true
eval $(docker-machine env default)
docker build $APP_DIR -t $APP_IMAGE
docker push $APP_IMAGE
docker build $DB_DIR -t $DB_IMAGE
docker push $DB_IMAGE
docker build $PROXY_DIR -t $PROXY_IMAGE
docker push $PROXY_IMAGE

# create nodes
for i in 1 2; do
    docker-machine create $MACHINE_FLAGS $NODE-$i \
        || docker-machine start $NODE-$i \
        || true
done

# init swarm with node-1
TOKEN=''

# add other nodes to swarm
for i in 1 2; do
    eval $(docker-machine env $NODE-$i)
    if [[ $i == '1' ]]; then
        docker swarm init \
            --advertise-addr $(docker-machine ip $NODE-1) \
            --listen-addr $(docker-machine ip $NODE-1):$NET_PORT
        TOKEN=$(docker swarm join-token -q worker)
    else
        docker swarm join \
            --token $TOKEN \
            $(docker-machine ip $NODE-1):$NET_PORT
    fi
done

# create network layers
eval $(docker-machine env $NODE-1)
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
