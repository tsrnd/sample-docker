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

eval "$(docker-machine env default)"
if ! docker ps | grep 'registry:2'; then
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

SECTION 'Define'

swarm_master='node-01'
net_local='swarm-local'
net_public='swarm-public'

app_name='chat'
app_image="$registry/$app_name"
app_scale='1'
app_host='/api'

web_name='web'
web_image="$registry/$web_name"
web_scale='1'

db_name='redis'
db_image="redis:3.2.6"
db_scale='1'

proxy_name='proxy'
proxy_image='dockercloud/haproxy:1.6.2'

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
# docker service ls | grep "$proxy_name" && docker service rm $proxy_name
docker service create \
    --name $proxy_name \
    --mode global \
    --network $net_local \
    --network $net_public \
    --mount target=/var/run/docker.sock,source=/var/run/docker.sock,type=bind \
    --constraint 'node.role==manager' \
    -p 80:80 \
    -p 1936:1936 \
    -e STATS_AUTH=admin:admin \
    $proxy_image

log "create '$db_name'"
# docker service ls | grep "$db_name" && docker service rm $db_name
docker service create \
    --name $db_name \
    --replicas "$db_scale" \
    --network $net_local \
    --constraint 'node.role!=manager' \
    $db_image

log "create '$app_name'"
# docker service ls | grep "$app_name" && docker service rm $app_name
docker service create \
    --name $app_name \
    --replicas $app_scale \
    --network $net_local \
    --constraint 'node.role!=manager' \
    -e DB="$db_name" \
    -e PORT=3000 \
    -e SERVICE_PORTS=3000 \
    -e VIRTUAL_HOST="$app_host" \
    $app_image

log "create '$web_name'"
# docker service ls | grep "$web_name" && docker service rm $web_name
docker service create \
    --name $web_name \
    --replicas $web_scale \
    --network $net_local \
    --constraint 'node.role!=manager' \
    -e SERVICE_PORTS=80 \
    -e DB=$db_name \
    $web_image
