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

SECTION 'Define'

swarm_nodes=('node-01' 'node-02' 'node-03')
swarm_master='node-01'

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
    if [[ $node == "$swarm_master" ]]; then
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

SECTION 'Info'

eval "$(docker-machine env $swarm_master)"
docker node ls
swarm_ip="$(docker-machine ip $swarm_master)"
log "swarm ip: $swarm_ip"
open "http://$swarm_ip" -a 'Google Chrome'
