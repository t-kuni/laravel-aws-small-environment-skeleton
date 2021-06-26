FROM php:8.0.3-fpm-alpine3.13

#
# Install packages
#
RUN apk update \
    && apk add openssl openssl-dev \
    && apk add --no-cache --virtual build-tools autoconf automake libtool gcc libc-dev lcms2-dev nasm make
RUN apk add oniguruma-dev
RUN docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) mbstring \
    && docker-php-ext-install -j$(nproc) sockets
RUN pecl install redis-5.3.4
RUN docker-php-ext-enable redis

# Install GD
RUN apk add --no-cache libpng libpng-dev
RUN docker-php-ext-install gd

# Purge build tools
RUN apk del --purge build-tools

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Add user
ARG APP_UID=1000
ARG APP_GID=1000
RUN addgroup -g $APP_GID app
RUN adduser -u $APP_UID -G app -D -H -s /sbin/nologin app

#
# Copy configs
#
COPY php-fpm.conf   /usr/local/etc/php-fpm.conf
COPY www.conf       /usr/local/etc/php-fpm.d/www.conf
COPY php.ini        /usr/local/etc/php/php.ini
COPY start-fpm.sh   /start-fpm.sh
COPY start-crond.sh /start-crond.sh
COPY crontab        /var/spool/cron/crontabs/app

# Import source code
COPY --from=XXXX /var/www/app /var/www/app
WORKDIR /var/www/app

CMD ["/start-fpm.sh"]
