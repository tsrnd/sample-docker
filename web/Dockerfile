FROM php:7.1.0

RUN apt-get update && apt-get install -y curl nano
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

COPY . /var/www/
CMD cd /var/www && composer install
WORKDIR /var/www

EXPOSE 5000
CMD php artisan serve --port=5000
