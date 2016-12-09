FROM node:7.1.0

# provide cached layer for node_modules
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /usr/src && cp -a /tmp/node_modules /usr/src/

# define working dir
WORKDIR /usr/src
ADD . /usr/src/

# expose port
EXPOSE 3000

CMD ["npm", "start"]
