#!/bin/bash

# Continue on errors for debugging
# set -e

echo "🚀 Starting Laravel application..."

# Check if .env exists, create from example if not
if [ ! -f /app/.env ]; then
    echo "📄 Creating .env file from example..."
    cp /app/.env.example /app/.env
    php artisan key:generate --no-interaction --force

    # Configure sessions for file storage temporarily
    sed -i 's/SESSION_DRIVER=database/SESSION_DRIVER=file/' /app/.env
    sed -i 's/CACHE_STORE=database/CACHE_STORE=file/' /app/.env
fi

# Test basic Laravel functionality
echo "🧪 Testing Laravel configuration..."
php artisan --version || echo "❌ Laravel not working"

echo "✅ Database connection established"

# Run migrations
echo "🔄 Running database migrations..."
php artisan migrate --force --no-interaction

# Install Octane with FrankenPHP
echo "🚀 Installing Octane with FrankenPHP..."
php artisan octane:install --server=frankenphp --no-interaction

# Make the FrankenPHP binary executable
echo "🔧 Making FrankenPHP binary executable..."
chmod +x /usr/local/bin/frankenphp

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

# Ensure session directory has proper permissions
mkdir -p /app/storage/framework/sessions
chown -R www-data:www-data /app/storage/framework/sessions
chmod -R 777 /app/storage/framework/sessions

# Clear any cached config that might cause issues
php artisan config:clear --no-interaction || true
php artisan cache:clear --no-interaction || true

echo "✅ Laravel application ready!"

# Start supervisor to manage processes
echo "🚀 Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
