#!/bin/bash

APP=chat
APP_IMAGE=./chat
APP_DB=$APP-db
APP_DB_IMAGE=./data/redis
SDN_LOCAL=local
SDN_PUBLIC=public
SDN_PORT=2377
PROXY_FLOW=proxy-flow
PROXY_FLOW_IMAGE=./proxy

# create nodes
for i in 01 02 03; do
    docker-machine create -d virtualbox "node$i"
done

# init swarm with node01
eval $(docker-machine env node01)
docker swarm init \
    --advertise-addr $(docker-machine ip node01) \
    --listen-addr $(docker-machine ip node01):$SDN_PORT
TOKEN=$(docker swarm join-token -q worker)

# add other nodes to swarm
for i in 02 03; do
    eval $(docker-machine env "node$i")    
    docker swarm join \
        --token $TOKEN \
        $(docker-machine ip node01):$SDN_PORT
done

# create network layers
eval $(docker-machine env node01)
docker network create --driver overlay $SDN_PUBLIC
docker network create --driver overlay $SDN_LOCAL

# create service layers
docker service create --name $APP_DB \
    --network $SDN_LOCAL \
    $APP_DB_IMAGE
docker service create --name $APP \
    -e DB=$APP_DB \
    --network $SDN_LOCAL \
    --network $SDN_PUBLIC \
    $APP_IMAGE

docker service create --name $PROXY_FLOW \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    --network $SDN_PUBLIC \
    -e MODE=swarm \
    $PROXY_FLOW_IMAGE
docker service ps $PROXY_FLOW
