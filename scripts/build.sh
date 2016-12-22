#!/bin/bash

set -exo pipefail

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

create_machine() {
    NAME="$1"
    FLAGS="$2"
    docker-machine ls | grep $NAME && {
        docker-machine ls | grep $NAME | grep Running || docker-machine start $NAME
    } || {
        docker-machine create $MACHINE_FLAGS $FLAGS $NAME
    }
}

# build images
create_machine default
eval $(docker-machine env default)
docker build $APP_DIR -t $APP_IMAGE
docker push $APP_IMAGE
docker build $DB_DIR -t $DB_IMAGE
docker push $DB_IMAGE
docker build $PROXY_DIR -t $PROXY_IMAGE
docker push $PROXY_IMAGE

# create nodes
MASTER="$NODE-1"
for i in 1 2; do
    node="$NODE-$i"
    [[ $node == $MASTER ]] \
        && create_machine "$node" --swarm-master \
        || create_machine "$node" --swarm
done

# create networks
docker network create 

# create swarm
docker 


TOKEN=''
for i in 1 2; do    
    node="$NODE-$i"
    eval $(docker-machine env $node)    
    [[ $node == $MASTER ]] && {        
        docker node ls || {
            docker swarm init \
                --advertise-addr $(docker-machine ip $MASTER) \
                --listen-addr $(docker-machine ip $MASTER):$NET_PORT
        }         
        TOKEN=$(docker swarm join-token -q worker)       
    } || {
        docker swarm join \
            --token $TOKEN \
            $(docker-machine ip $MASTER):$NET_PORT \
            || true
    }
done
