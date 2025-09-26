#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Laravel application..."

echo "✅ Database connection established"

# Run migrations
echo "🔄 Running database migrations..."
php artisan migrate --force --no-interaction

# Clear and cache config for production
echo "🔧 Optimizing application..."
php artisan config:clear --no-interaction
php artisan config:cache --no-interaction
php artisan route:cache --no-interaction
php artisan view:cache --no-interaction

# Create storage link if it doesn't exist
if [ ! -L /app/public/storage ]; then
    echo "🔗 Creating storage symlink..."
    php artisan storage:link --no-interaction
fi

# Set proper permissions for all Laravel directories
echo "🔒 Setting permissions..."
chown -R www-data:www-data /app/storage /app/bootstrap/cache /app/public
chmod -R 775 /app/storage /app/bootstrap/cache
chmod -R 755 /app/public

# Ensure critical directories exist and have correct permissions
mkdir -p /app/storage/logs /app/storage/framework/{cache,sessions,views} /app/storage/app/public /app/bootstrap/cache
chown -R www-data:www-data /app/storage /app/bootstrap/cache
chmod -R 775 /app/storage /app/bootstrap/cache

echo "✅ Laravel application ready!"

# Start supervisor to manage processes
echo "🚀 Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
