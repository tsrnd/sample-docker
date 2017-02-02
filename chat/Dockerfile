FROM node:7.5.0
MAINTAINER DaoNV "daonv@asiantech.vn"

ENV WORK_DIR='/usr/src'
ENV CACHE_DIR='/cache/app/chat'

RUN mkdir -p "$WORK_DIR"

# yarn
RUN apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        yarn

# install dependences
WORKDIR "$CACHE_DIR"
COPY package.json .
COPY yarn.lock .
RUN yarn install && \
    yes | cp -rf . "$WORK_DIR/"

WORKDIR "$WORK_DIR"
COPY . .

EXPOSE 3000
CMD ["yarn", "start"]
