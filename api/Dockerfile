FROM node:7.1.0

ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /usr/src && cp -a /tmp/node_modules /usr/src/

WORKDIR /usr/src
ADD . /usr/src/

EXPOSE 3000
CMD ["npm", "start"]
