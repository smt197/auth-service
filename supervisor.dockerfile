# Image de base FrankenPHP
FROM dunglas/frankenphp:latest-php8.3


# Installer les extensions PHP nécessaires pour Laravel
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
   pcntl


# Installer composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Installer Node.js et supervisor
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y nodejs supervisor \
    && rm -rf /var/lib/apt/lists/*


# Définir le répertoire de travail
WORKDIR /app


# Copier TOUT le projet Laravel
COPY . /app

# Créer les répertoires nécessaires d'abord
RUN mkdir -p /app/storage/app/public \
    /app/storage/framework/cache \
    /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/logs \
    /app/bootstrap/cache \
    && chown -R www-data:www-data /app/storage /app/bootstrap/cache \
    && chmod -R 775 /app/storage /app/bootstrap/cache

# Install PHP extensions
RUN pecl install xdebug

# Enable PHP extensions
RUN docker-php-ext-enable xdebug

# Installer les dépendances PHP (après création des répertoires)
RUN composer install --no-dev --optimize-autoloader --no-interaction



# Copier la configuration supervisor
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copier et configurer le script de démarrage
COPY supervisor/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exposer les ports
EXPOSE 80 443 2019


# Utiliser le script de démarrage qui lance supervisor
CMD ["/usr/local/bin/docker-entrypoint.sh"]


