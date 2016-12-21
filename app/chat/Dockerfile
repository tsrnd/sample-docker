FROM 172.16.110.141:5000/node:7.1.0
MAINTAINER DaoNV "daonv@asiantech.vn"

ENV WORK_DIR='/usr/src'
ENV CACHE_DIR='/cache/app/chat'

RUN mkdir -p "$WORK_DIR"

RUN apt-get update
RUN apt-get install -y apt-utils

# yarn
RUN apt-get install -y apt-transport-https
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y yarn

# install dependences
WORKDIR "$CACHE_DIR"
COPY package.json .
COPY yarn.lock .
RUN yarn install
RUN yes | cp -rf . "$WORK_DIR/"

WORKDIR "$WORK_DIR"
COPY . .
EXPOSE 3000
CMD ["yarn", "start"]
