FROM php:7.1.0

RUN apt-get update && apt-get install -y curl nano
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

COPY . /usr/src/
CMD cd /usr/src && composer install
WORKDIR /usr/src

CMD php artisan serve --port=9000
