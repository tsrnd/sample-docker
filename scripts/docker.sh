#!/bin/bash
sudo apt-get update && \
    sudo apt-get install -y apt-utils
sudo apt-get install -y curl \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates
curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get install software-properties-common
sudo add-apt-repository \
    "deb https://apt.dockerproject.org/repo/ \
    ubuntu-$(lsb_release -cs) \
    main"
sudo apt-get update && \
    sudo apt-get -y install docker-engine
docker info
