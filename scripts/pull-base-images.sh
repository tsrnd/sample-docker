#!/bin/bash
set -o pipefail
docker-machine start default
eval "$(docker-machine env default)"
echo 'Caching base images...'
registry='172.16.110.141:5000'
for i in node:7.1.0 redis:3.2.5 dockercloud/haproxy:1.6.2 php:7.1.0 mysql:8.0.0 swarm:1.2.5 ; do  
    old=$i
    old_name=${i%:*}
    tag=${i##*:}  
    new_name="$registry/$old_name"
    new="$new_name:$tag"
    docker images | grep "$new_name" | grep "$tag" || docker pull $new && {
        echo "Image '$old' was cached as '$new'"
        continue
    }
    docker pull $old && docker tag $old $new && docker push $new
done
echo 'Done!'
