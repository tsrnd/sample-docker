#!/bin/bash

OS=$(uname -a)

if [[ $OS == Linux* ]]; then  
    sudo apt-get update
    sudo apt-get install \
        apt-utils \
        apt-transport-https \
        ca-certificates
    # Docker
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
        --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-get update
    apt-cache policy docker-engine
    sudo apt-get install \
            linux-image-extra-$(uname -r) \
            linux-image-extra-virtual \
            docker-engine
    sudo service docker start
    sudo curl \
        -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose  
    # NodeJS
    groupadd --gid 1000 node \
        && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

    set -ex \
        && for key in \
            9554F04D7259F04124DE6B476D5A82AC7E37093B \
            94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
            0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
            FD3A5288F042B6850C66B31F09FE44734EB7990E \
            71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
            DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
            B9AE9905FFD7803F25714661B63B535A4C206CA9 \
            C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        ; do \
            gpg --keyserver pool.sks-keyservers.net --recv-keys "$key"; \
        done

    export NODE_VERSION=7.1.0
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
    grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c -
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

    # Yarn
    apt-get install -y \
        apt-transport-https \
        git
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    apt-get install -y yarn

    # Task
    yarn add -g gulp
else
  # Homebrew
  sudo chown -R $(whoami):admin '/usr/local'
  if ! which brew > /dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/master/install')"
  fi
  # Docker
  brew install docker

  # NodeJS

  # Yarn
  brew install yarn

  # Task
    yarn add -g gulp
fi