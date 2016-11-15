#!/bin/bash
set -eux -o pipefail
docker ps -aq | xargs docker rm -f
