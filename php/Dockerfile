FROM php:7.1.0

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y curl nano nodejs yarn

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

RUN mkdir /var/www/html
COPY . /var/www/html/
CMD cd /var/www/html && \
    composer install && \
    yarn install && \
    chmod -R 775 /var/www/html/storage

WORKDIR /usr/src
EXPOSE 9000
ENTRYPOINT ["yarn", "start"]
