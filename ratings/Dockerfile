FROM php:7.4-apache

EXPOSE 80

RUN apt-get update && apt-get install -yqq unzip libzip-dev \
    && docker-php-ext-install pdo_mysql opcache zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY status.conf /etc/apache2/mods-available/status.conf
RUN a2enmod rewrite && a2enmod status

WORKDIR /var/www/html

COPY html/ /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install

RUN rm -Rf /var/www/var/* \
    && chown -R www-data:www-data /var/www \
    && chmod -R 777 /var/www
