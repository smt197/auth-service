FROM serversideup/php:8.3-fpm-nginx-alpine

ENV PHP_OPCACHE_ENABLE=1

WORKDIR /var/www/html

USER root

# Install PHP extensions and prepare directories in one layer
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
       sockets \
    && mkdir -p storage/logs \
               storage/framework/cache \
               storage/framework/sessions \
               storage/framework/views \
               storage/app \
               bootstrap/cache \
    && touch storage/logs/laravel.log \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Copy custom automations script
COPY --chown=root:root automations.sh /etc/entrypoint.d/60-custom-automations.sh
RUN chmod +x /etc/entrypoint.d/60-custom-automations.sh

# Copy application files
COPY --chown=www-data:www-data . .

# Switch to non-root user
USER www-data

# Install dependencies and setup Laravel in one layer
RUN composer install --no-interaction --optimize-autoloader --no-dev \
    && composer require laravel/octane --no-interaction \
    && php artisan octane:install --server=frankenphp --no-interaction \
    && rm -rf ~/.composer/cache