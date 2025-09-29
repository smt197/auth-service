FROM serversideup/php:8.3-fpm-nginx-alpine

ENV PHP_OPCACHE_ENABLE=1

WORKDIR /var/www/html

USER root

# Install PHP extensions
RUN install-php-extensions \
       pdo_mysql \
       mysqli \
       mbstring \
       xml \
       zip \
       bcmath \
       gd \
       redis \
       opcache \
       pcntl \
       sockets

# Copy s6-overlay services for Laravel
COPY s6-overlay /etc/s6-overlay/
RUN find /etc/s6-overlay -name "run" -type f -exec chmod +x {} \;

# Copy application files
COPY --chown=www-data:www-data . .

# Create storage directories and fix permissions as root
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views storage/app bootstrap/cache \
    && touch storage/logs/laravel.log \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chmod -R 777 storage/logs \
    && chmod 666 storage/logs/laravel.log

# Switch to non-root user
USER www-data

# Install dependencies and setup Laravel in one layer
RUN composer install --no-interaction --optimize-autoloader --no-dev \
    && composer require laravel/octane --no-interaction \
    && php artisan octane:install --server=frankenphp --no-interaction \
    && rm -rf ~/.composer/cache