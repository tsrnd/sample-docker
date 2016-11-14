#!/bin/bash
set -eu -o pipefail
docker ps -aq | xargs docker rm -f
