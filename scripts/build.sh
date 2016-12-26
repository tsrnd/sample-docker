#!/bin/bash

set -o pipefail

SECTION() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

SECTION 'Define'

iso_url="file://$HOME/.docker/machine/boot2docker.iso"
registry='172.16.110.141:5000'
machine_flags="-d virtualbox
    --virtualbox-boot2docker-url $iso_url
    --virtualbox-memory 1024
    --virtualbox-cpu-count 1
    --virtualbox-no-share
    --virtualbox-no-vtx-check
    --engine-insecure-registry $registry"

swarm_port='2377'
swarm_nodes=('node-01' 'node-02' 'node-03')
swarm_master='node-01'
net_local='swarm-local'
net_public='swarm-public'

app_name='chat'
app_dir='./app/chat'
app_ver='0.0.0'
app_image="$registry/$app_name:$app_ver"
app_scale='2'
app_port='3000'

db_name='redis'
db_image="$registry/redis:3.2.5"
db_port='6379'

proxy_name='proxy'
proxy_image="$registry/dockercloud/haproxy:1.6.2"
proxy_port='80'
proxy_stats_port='1936'
proxy_stats_user='admin'
proxy_stats_pass='admin'

create_node() {
    local name="$1"
    log "create node '$name'"
    {
        docker-machine ls | grep "$name" && {
            docker-machine ls \
                | grep "$name" | grep "Running" \
                || docker-machine start $name
        } || {
            docker-machine create $machine_flags $name
        }
    } > /dev/null
}

SECTION 'Images'

create_node default
eval $(docker-machine env default)
log "build $app_image"
docker images | grep "$registry/$app_name" | grep "$app_ver" && docker rmi $app_image > /dev/null
docker build $app_dir -t $app_image > /dev/null
docker push $app_image > /dev/null

SECTION 'Swarm Nodes'

docker-machine ls -q | grep -v default | xargs docker-machine rm -y > /dev/null
for node in "${swarm_nodes[@]}"; do
    create_node "$node"
done

SECTION 'Swarm'
token=''
swarm_ip="$(docker-machine ip $swarm_master)"
for node in "${swarm_nodes[@]}"; do
    eval $(docker-machine env $node)
    log 'remove old containers'
    # docker ps -aq | xargs docker rm -f
    [[ $node == $swarm_master ]] && {
        log "init swarm at node '$node'"
        docker node ls || {
            docker swarm init \
                --advertise-addr $swarm_ip \
                --listen-addr $swarm_ip:$swarm_port > /dev/null
        }
        log 'get swarm join token'
        token=$(docker swarm join-token -q worker)
    } || {
        log "add node '$node' to swarm"
        docker swarm join \
            --token $token \
            $swarm_ip:$swarm_port > /dev/null
    }
done

eval $(docker-machine env $swarm_master)

SECTION 'Networks'

log "create '$net_local'"
docker network ls | grep "$net_local" \
    || docker network create \
        --driver overlay \
        $net_local

log "create '$net_public'"
docker network ls | grep "$net_public" \
    || docker network create \
        --driver overlay \
        $net_public

SECTION 'Services'

log "create '$proxy_name'"
docker service ls | grep "$proxy_name" && docker service rm $proxy_name > /dev/null
docker service create \
    --name $proxy_name \
    --mode global \
    --network $net_local \
    --network $net_public \
    --mount target=/var/run/docker.sock,source=/var/run/docker.sock,type=bind \
    --constraint "node.role == manager" \
    -p "$proxy_port:$proxy_port" \
    -p "$proxy_stats_port:$proxy_stats_port" \
    -e STATS_AUTH="$proxy_stats_user:$proxy_stats_pass" \
    $proxy_image

log "create '$db_name'"
docker service ls | grep "$db_name" && docker service rm $db_name > /dev/null
docker service create \
    --name $db_name \
    --replicas 1 \
    --network $net_local \
    --constraint "node.role != manager" \
    -p "$db_port:$db_port" \
    $db_image

log "create '$app_name'"
docker service ls | grep "$app_name" && docker service rm $app_name > /dev/null
docker service create \
    --name $app_name \
    --replicas 1 \
    --network $net_local \
    --constraint "node.role != manager" \
    -e SERVICE_PORTS="$app_port" \
    -e DB="$db_name" \
    -p "$app_port:$app_port" \
    $app_image

SECTION 'Info'

docker node ls
docker service ls

swarm_ip="$(docker-machine ip $swarm_master)"
log "swarm ip: $swarm_ip"

open "http://$swarm_ip" -a 'Google Chrome'
