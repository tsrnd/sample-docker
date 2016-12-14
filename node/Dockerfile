FROM node:7.1.0

RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH "$PATH:$HOME/.yarn/bin"

RUN mkdir /usr/src
COPY . /usr/src/
CMD cd /usr/src && \
    yarn install

WORKDIR /usr/src
EXPOSE 3000
CMD ["yarn", "start"]
