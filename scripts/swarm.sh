#!/bin/bash

set -eo pipefail

section() {
    echo "=== $1"
}

log() {
    echo "> $1"
}

clear

section 'Prepare'

REGISTRY_MACHINE='default'
docker-machine start "$REGISTRY_MACHINE" || true
eval "$(docker-machine env $REGISTRY_MACHINE)"
REGISTRY="$(docker-machine ip $REGISTRY_MACHINE):5000"

sleep 3

if ! docker ps | grep 'registry:2'; then
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

create_machine() {
    local MACHINE_NAME="$1"
    log "create node '$MACHINE_NAME'"
    if docker-machine ls | grep "$MACHINE_NAME"; then
        if ! docker-machine ls | grep "$MACHINE_NAME" | grep "Running"; then
            docker-machine start "$MACHINE_NAME"
        fi
    else
        docker-machine create -d virtualbox \
            --virtualbox-boot2docker-url "file://$HOME/.docker/machine/1.12.5.iso" \
            --virtualbox-memory 1024 \
            --virtualbox-cpu-count 1 \
            --virtualbox-no-share \
            --virtualbox-no-vtx-check \
            --engine-insecure-registry "$REGISTRY" \
            "$MACHINE_NAME"
    fi
}

section 'Define'

SWARM_NODES=('node-01' 'node-02' 'node-03')
SWARM_MASTER='node-01'

section 'Swarm Nodes'

# docker-machine ls -q | grep -v "$REGISTRY_MACHINE" | xargs docker-machine rm -y
for NODE in "${SWARM_NODES[@]}"; do
    create_machine "$NODE"
done

section 'Swarm'
TOKEN=''
SWARM_IP="$(docker-machine ip $SWARM_MASTER)"
for NODE in "${SWARM_NODES[@]}"; do
    if ! docker-machine env "$NODE" ; then
        docker-machine regenerate-certs "$NODE" -f
    fi
    eval "$(docker-machine env "$NODE")"
    log 'remove old containers'
    docker ps -aq | xargs docker rm -f
    if [[ $NODE == "$SWARM_MASTER" ]]; then
        docker swarm init --advertise-addr "$SWARM_IP" --listen-addr "$SWARM_IP:2377" || true
        log 'get swarm join-token'
        TOKEN="$(docker swarm join-token -q worker)"
    else
        docker swarm join --token "$TOKEN" "$SWARM_IP:2377" || true
    fi
done

section 'Info'

eval "$(docker-machine env "$SWARM_MASTER")"
docker node ls
