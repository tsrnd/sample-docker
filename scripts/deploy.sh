#!/bin/bash
set -e -o pipefail
MASTER='node-chat-1'
eval "$(docker-machine env --swarm $MASTER)"
docker-compose scale app-chat=2
docker-compose up -d
