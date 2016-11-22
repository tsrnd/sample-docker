#!/bin/bash

OS=$(uname -a)

if [[ $OS == Linux* ]]; then
  # Install git first.
  # sudo apt-get install git

  # Update package information, ensure that APT works with the https method, and that CA certificates are installed.
  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates
  # Add the new GPG key.
  sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  # Subscribe Docker sources. (Ubuntu 14.04 LTS)
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list

  # Update the APT package index
  sudo apt-get update

  # Verify that APT is pulling from the right repository.
  apt-cache policy docker-engine

  # Install the linux-image-extra-* packages.
  sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual

  # Install Docker.
  sudo apt-get install docker-engine

  # Start the Docker daemon.
  sudo service docker start

  # Install Docker Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose  
else
  # Grant permission.
  sudo chown -R $(whoami):admin '/usr/local'
  if ! which brew > /dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/master/install')"
  fi

  # Grant permission.
  sudo chown -R $(whoami):admin '/Library/Caches/Homebrew'

  # Install Docker.
  brew install docker
fi