#!/bin/bash
docker-machine ls -q | grep -v default | xargs docker-machine rm -y