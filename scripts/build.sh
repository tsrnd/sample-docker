#!/bin/bash

set -o pipefail

SECTION() {
    echo "=== $1"
}

SECTION 'Define'

registry='172.16.110.141:5000'
machine_flags="-d virtualbox
    --virtualbox-boot2docker-url file://$HOME/.docker/machine/boot2docker.iso
    --virtualbox-memory 1024
    --virtualbox-cpu-count 1
    --virtualbox-no-share
    --virtualbox-no-vtx-check
    --engine-insecure-registry $registry"

swarm_port='2377'
swarm_nodes=('node-01' 'node-02' 'node-03')
swarm_master='node-01'
net_local='local'
net_public='public'
net_subnet='10.0.9.0/24'

app_name='chat'
app_dir='./app/chat'
app_image="$registry/$app_name:0.0.0"
app_scale='2'

db_name='redis'
db_dir='./data/redis'
db_image="$registry/$db_name:0.0.0"

proxy_name='proxy'
proxy_dir='./proxy'
proxy_image="$registry/$proxy_name:0.0.0"

create_node() {
    local name="$1"
    echo "create node \"$name\""
    {
        docker-machine ls | grep $name && { 
            docker-machine ls | grep "$name" | grep "Running" || docker-machine start $name
        } || {
            docker-machine create $machine_flags $name
        }
    } > /dev/null
}

SECTION 'Images'

create_node default
eval $(docker-machine env default)
echo "build $app_image"
docker build $app_dir -t $app_image > /dev/null
docker push $app_image > /dev/null
echo "build $db_image"
docker build $db_dir -t $db_image > /dev/null
docker push $db_image > /dev/null
echo "build $proxy_image"
docker build $proxy_dir -t $proxy_image > /dev/null
docker push $proxy_image > /dev/null

SECTION 'Swarm Nodes'
for node in "${swarm_nodes[@]}"; do
    create_node "$node"
done

SECTION 'Swarm'
token=''
for node in "${swarm_nodes[@]}"; do    
    eval $(docker-machine env $node)
    {
        [[ $node == $swarm_master ]] && {  
            echo "init swarm at node \"$node\" "
            docker node ls || {
                docker swarm init \
                    --advertise-addr $(docker-machine ip $node) \
                    --listen-addr $(docker-machine ip $node):$swarm_port
            }
            echo 'get swarm join token'
            token=$(docker swarm join-token -q worker)       
        } || {
            echo "add node \"$node\" to swarm"
            docker swarm join \
                --token $token \
                $(docker-machine ip $swarm_master):$swarm_port \
                || true
        }
    } > /dev/null
done

eval $(docker-machine env $swarm_master)

SECTION 'Networks'

echo "create \"$net_local\""
docker network ls | grep $net_local \
    || docker network create \
        --driver overlay \
        --subnet $net_subnet \
        $net_local

echo "create \"$net_public\""
docker network ls | grep $net_public \
    || docker network create \
        --driver overlay \
        --subnet $net_subnet \
        $net_public

SECTION 'Services'

echo "create \"$db_name\""
docker service ls | grep $db_name \
    || docker service create \
        --replicas 1 \
        --name $db_name \
        --network $net_local \
        $db_image

echo "create \"$app_name\""
docker service ls | grep $app_name \
    || docker service create \
        --replicas 1 \
        --name $app_name \
        --network $net_local \
        -e DB=$db_name \
        $app_image

echo "create \"$proxy_name\""
docker service ls | grep $proxy_name \
    || docker service create \
        --replicas 1 \
        --name $proxy_name \
        --network $net_local \
        --network $net_public \
        -p 80:80 \
        -p 8080:8080 \
        -p 443:443 \
        -e MODE='swarm' \
        $proxy_image
