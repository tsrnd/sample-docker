#!/bin/bash
eval "$(docker-machine env default)"
echo 'Caching base images...'
REGISTRY='172.16.110.141:5000'
for i in node:7.1.0 redis:3.2.5 haproxy:1.7.1 php:7.1.0 mysql:8.0.0 swarm:1.2.5 ; do  
    NAME=${i%:*}
    TAG=${i##*:}  
    NEW="$REGISTRY/$NAME"
    IMG="$NEW:$TAG"
    if [[ $(docker images | grep "$NEW" | grep "$TAG") || $(docker pull $IMG) ]]; then
        echo "Image '$i' was cached as '$IMG'"
        continue
    fi
    docker pull $i
    docker tag $i $IMG
    docker push $IMG
done
echo 'Done!'
