#!/bin/bash

docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
echo 'Removed exited containers...'
docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
echo 'Removed dangling images...'
