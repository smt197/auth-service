FROM serversideup/php:8.3-fpm-nginx-alpine

ENV PHP_OPCACHE_ENABLE=1

USER root

# Install required PHP extensions and system dependencies
RUN install-php-extensions \
    openssl \
    curl \
    opcache \
    pcntl \
    intl \
    gd
# Copy application files
COPY --chown=www-data:www-data . /var/www/html

# Switch to non-root user
USER www-data

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Install Laravel Octane first (before other dependencies)
RUN composer require laravel/octane --no-interaction --ignore-platform-reqs \
    && php artisan octane:install --server=frankenphp --no-interaction


# Remove composer cache
RUN rm -rf /var/www/html/.composer/cache