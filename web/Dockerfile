FROM php:7.1.0-fpm
MAINTAINER DaoNV "daonv@asiantech.vn"

ENV WORK_DIR='/var/www'
ENV CACHE_DIR='/cache/app/web'

RUN mkdir -p "$WORK_DIR"

RUN apt-get update && \
    apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        apt-utils

# nodejs
ENV NODE_VERSION 7.1.0
RUN groupadd --gid 1000 node && \
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node && \
    set -ex && \
    for key in \
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
    done && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
    grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

# yarn
RUN apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        apt-transport-https \
        git
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        yarn

# composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin/ --filename=composer

# install dependences
WORKDIR "$CACHE_DIR"
COPY package.json .
COPY yarn.lock .
RUN yarn install && \
    echo 'yes' | cp -rf . "$WORK_DIR/"

WORKDIR "$WORK_DIR"
COPY . .
RUN composer install && \
    echo 'yes' | cp -rf vendor "$CACHE_DIR" && \
    chmod -R 775 storage

COPY php-fpm.conf /etc/php7/php-fpm.conf
RUN ln -s /usr/bin/php7 /usr/bin/php

EXPOSE 9000
CMD ["yarn", "start"]
