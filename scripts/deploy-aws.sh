#!/bin/bash

set -eo pipefail

SECTION() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

clear

SECTION 'Prepare'

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

swarm_nodes=('node-01' 'node-02' 'node-03')
swarm_master='node-01'
net_local='swarm-local'
net_public='swarm-public'

app_name='chat'
app_dir='./chat'
app_image="$registry/$app_name"
app_scale='1'
app_host='/api'

web_name='web'
web_dir='./web'
web_image="$registry/$web_name"
web_scale='1'

db_name='redis'
db_image="redis:3.2.6"
db_scale='1'

proxy_name='proxy'
proxy_image="dockercloud/haproxy:1.6.2"

SECTION 'Images'

log "build $app_image"
# docker images | grep "$registry/$app_name" && docker rmi $app_image
docker build $app_dir -t $app_image
docker push $app_image

log "build $web_image"
# docker images | grep "$registry/$web_name" && docker rmi $web_image
docker build $web_dir -t $web_image
docker push $web_image

SECTION 'Swarm Nodes'

# docker-machine ls -q | grep -v default | xargs docker-machine rm -y
for node in "${swarm_nodes[@]}"; do
    create_machine "$node"
done

SECTION 'Swarm'
token=''
swarm_ip="$(docker-machine ip $swarm_master)"
for node in "${swarm_nodes[@]}"; do
    eval "$(docker-machine env "$node")"
    log 'remove old containers'
    docker ps -aq | xargs docker rm -f
    if [[ "$node" == "$swarm_master" ]]; then
        log "init swarm at node '$node'"
        docker node ls || {
            docker swarm init \
                --advertise-addr "$swarm_ip" \
                --listen-addr "$swarm_ip:2377"
        }
        log 'get swarm join token'
        token=$(docker swarm join-token -q worker)
    else
        log "add node '$node' to swarm"
        docker swarm leave || true
        docker swarm join \
            --token "$token" \
            "$swarm_ip:2377"
    fi
done

eval "$(docker-machine env $swarm_master)"

SECTION 'Networks'

log "create '$net_local'"

if docker network ls | grep "$net_local"; then
    docker network rm "$net_local" -f
fi
docker network create \
    --driver overlay \
    --subnet=10.0.9.0/24 \
    $net_local

log "create '$net_public'"
if docker network ls | grep "$net_public"; then
    docker network rm "$net_public" -f
fi
docker network create \
    --driver overlay \
    --subnet=10.0.9.0/24 \
    $net_public

SECTION 'Services'

log "create '$proxy_name'"
docker service ls | grep "$proxy_name" && docker service rm $proxy_name
docker service create \
    --name $proxy_name \
    --mode global \
    --network $net_local \
    --network $net_public \
    --mount target=/var/run/docker.sock,source=/var/run/docker.sock,type=bind \
    --constraint "node.role == manager" \
    -p '80:80' \
    -p '1936:1936' \
    -e STATS_AUTH='admin:admin' \
    $proxy_image

log "create '$db_name'"
docker service ls | grep "$db_name" && docker service rm $db_name
docker service create \
    --name $db_name \
    --replicas "$db_scale" \
    --network $net_local \
    --constraint "node.role != manager" \
    $db_image

log "create '$app_name'"
docker service ls | grep "$app_name" && docker service rm $app_name
docker service create \
    --name $app_name \
    --replicas $app_scale \
    --network $net_local \
    --constraint "node.role != manager" \
    -e DB="$db_name" \
    -e SERVICE_PORTS='3000' \
    -e VIRTUAL_HOST="$app_host" \
    $app_image

log "create '$web_name'"
docker service ls | grep "$web_name" && docker service rm $web_name
docker service create \
    --name $web_name \
    --replicas $web_scale \
    --network $net_local \
    --constraint "node.role != manager" \
    -e SERVICE_PORTS='80' \
    -e DB="$db_name" \
    $web_image

SECTION 'Info'

swarm_ip="$(docker-machine ip $swarm_master)"
log "swarm ip: $swarm_ip"

open "http://$swarm_ip" -a 'Google Chrome'
open "http://$swarm_ip$app_host" -a 'Google Chrome'
