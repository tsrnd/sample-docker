FROM node:7.1.0

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
    apt-get install yarn

RUN mkdir /usr/src
COPY . /usr/src/
CMD cd /usr/src && \
    yarn install

WORKDIR /usr/src
EXPOSE 3000
CMD ["yarn", "start"]
