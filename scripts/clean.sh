#!/bin/bash

eval "$(docker-machine env default)"
docker ps -q | xargs docker rm -f
docker images -q | xargs docker rmi -f
docker network ls -q | xargs docker network rm
docker service ls -q | xargs docker service rm -f
docker-machine ls -q | xargs docker-machine rm -f
