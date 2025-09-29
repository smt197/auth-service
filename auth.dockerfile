FROM serversideup/php:8.3-fpm-nginx-alpine

ENV PHP_OPCACHE_ENABLE=1

USER root

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

# Copy application files
COPY --chown=www-data:www-data . /var/www/html

# Switch to non-root user
USER www-data

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Install Laravel Octane first (before other dependencies)
RUN composer require laravel/octane --no-interaction --ignore-platform-reqs \
    && php artisan octane:install --server=frankenphp --no-interaction

# Set Laravel directory permissions
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views storage/app bootstrap/cache \
    && touch storage/logs/laravel.log \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache \
    && chmod -R 777 storage/logs \
    && chmod 666 storage/logs/laravel.log

# Remove composer cache
RUN rm -rf /var/www/html/.composer/cache