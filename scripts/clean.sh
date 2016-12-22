#!/bin/bash

eval "$(docker-machine env default)"
docker ps -q | xargs docker rm -f
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
docker network ls -q | xargs docker network rm
docker service ls -q | xargs docker service rm -f
docker-machine ls -q | grep -v default | xargs docker-machine rm -y
