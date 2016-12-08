FROM node:7.1.0

# provide cached layer for node_modules
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /src && cp -a /tmp/node_modules /src/

# define working dir
WORKDIR /src
ADD . /src

# expose port
EXPOSE 3000

CMD ["npm", "start"]
