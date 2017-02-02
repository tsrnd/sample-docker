#!/bin/bash

set -eo pipefail

section() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

section 'Prepare'

REGISTRY_MACHINE='registry'
eval "$(docker-machine env $REGISTRY_MACHINE)"
REGISTRY="$(docker-machine ip $REGISTRY_MACHINE):5000"

sleep 3

if ! docker ps | grep 'registry:2'; then
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

section 'Define'

SWARM_MASTER='node-01'
NET_LOCAL='swarm-local'
NET_PUBLIC='swarm-public'

APP_NAME='chat'
APP_IMAGE="$REGISTRY/$APP_NAME:latest"
APP_SCALE='1'
APP_HOST='/api'
APP_PORT='3000'

WEB_NAME='web'
WEB_IMAGE="$REGISTRY/$WEB_NAME:latest"
WEB_SCALE='1'
WEB_PORT='9000'

DB_NAME='redis'
DB_IMAGE="redis:3.2.6"
DB_SCALE='1'

PROXY_NAME='proxy'
PROXY_IMAGE='dockercloud/haproxy:1.6.2'

sleep 3

section 'Services'
eval "$(docker-machine env $SWARM_MASTER)"

for SERVICE_ID in $(docker service ls -q); do
    docker service rm "$SERVICE_ID";
done

log "create '$PROXY_NAME'"
docker service create \
    --name $PROXY_NAME \
    --mode global \
    --constraint 'node.role==manager' \
    --network $NET_PUBLIC \
    --mount target=/var/run/docker.sock,source=/var/run/docker.sock,type=bind \
    -p 80:80 \
    -p 1936:1936 \
    -e STATS_AUTH=admin:admin \
    "$PROXY_IMAGE"

sleep 3

log "create '$DB_NAME'"
docker service create \
    --name $DB_NAME \
    --replicas $DB_SCALE \
    --constraint 'node.role!=manager' \
    --network $NET_LOCAL \
    "$DB_IMAGE"

sleep 3

log "create '$APP_NAME'"
docker service create \
    --name $APP_NAME \
    --replicas $APP_SCALE \
    --constraint 'node.role!=manager' \
    --network $NET_LOCAL \
    --network $NET_PUBLIC \
    -p 5000:5000 \
    -e DB=$DB_NAME \
    -e SERVICE_PORTS=$APP_PORT \
    -e VIRTUAL_HOST=$APP_HOST \
    "$APP_IMAGE"

sleep 3

log "create '$WEB_NAME'"
docker service create \
    --name $WEB_NAME \
    --replicas $WEB_SCALE \
    --constraint 'node.role!=manager' \
    --network $NET_LOCAL \
    --network $NET_PUBLIC \
    -p 9000:9000 \
    -e SERVICE_PORTS=$WEB_PORT \
    -e DB=$DB_NAME \
    "$WEB_IMAGE"

sleep 3

docker node ls
for SERVICE_ID in $(docker service ls -q); do
    docker service ps "$SERVICE_ID";
done

SWARM_IP="$(docker-machine ip $SWARM_MASTER)"
log "swarm ip: $SWARM_IP"
open "http://$SWARM_IP" -a 'Google Chrome'
