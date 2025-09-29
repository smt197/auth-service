#!/bin/sh
script_name="laravel-automations-octane"

# Set APP_BASE_DIR if not set
: "${APP_BASE_DIR:=/var/www/html}"

test_db_connection() {
    php -r "
        require '$APP_BASE_DIR/vendor/autoload.php';
        use Illuminate\Support\Facades\DB;

        \$app = require_once '$APP_BASE_DIR/bootstrap/app.php';
        \$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
        \$kernel->bootstrap();

        \$driver = DB::getDriverName();

            if( \$driver === 'sqlite' ){
                echo 'SQLite detected';
                exit(0); // Assume SQLite is always ready
            }

        try {
            DB::connection()->getPdo(); // Attempt to get PDO instance
            if (DB::connection()->getDatabaseName()) {
                exit(0); // Database exists and can be connected to, exit with status 0 (success)
            } else {
                echo 'Database name not found.';
                exit(1); // Database name not found, exit with status 1 (failure)
            }
        } catch (Exception \$e) {
            echo 'Database connection error: ' . \$e->getMessage();
            exit(1); // Connection error, exit with status 1 (failure)
        }
    "
}

# Set default values for Laravel automations
: "${AUTORUN_ENABLED:=false}"
: "${AUTORUN_LARAVEL_MIGRATION_TIMEOUT:=30}"
: "${AUTORUN_LARAVEL_OCTANE:=true}"
: "${OCTANE_SERVER:=frankenphp}"
: "${OCTANE_HOST:=0.0.0.0}"
: "${OCTANE_PORT:=8000}"

if [ "$DISABLE_DEFAULT_CONFIG" = "false" ]; then
    # Check to see if an Artisan file exists and assume it means Laravel is configured.
    if [ -f "$APP_BASE_DIR/artisan" ] && [ "$AUTORUN_ENABLED" = "true" ]; then
        echo "🚀 Running Laravel automations with Octane..."

        ############################################################################
        # Database Connection Test
        ############################################################################
        if [ "${AUTORUN_LARAVEL_MIGRATION:=true}" = "true" ]; then
            echo "⏳ Testing database connection..."
            count=0
            timeout=$AUTORUN_LARAVEL_MIGRATION_TIMEOUT

            until test_db_connection; do
                count=$((count + 1))
                if [ $count -gt $timeout ]; then
                    echo "❌ Database connection timeout after ${timeout} seconds"
                    exit 1
                fi
                echo "🔄 Waiting for database... (${count}/${timeout})"
                sleep 1
            done
            echo "✅ Database connection successful"
        fi

        ############################################################################
        # Laravel Migrations
        ############################################################################
        if [ "${AUTORUN_LARAVEL_MIGRATION:=true}" = "true" ]; then
            echo "📊 Running Laravel migrations..."
            if [ "${AUTORUN_LARAVEL_MIGRATION_ISOLATION:=false}" = "true" ]; then
                php "$APP_BASE_DIR/artisan" migrate --force --isolated
            else
                php "$APP_BASE_DIR/artisan" migrate --force
            fi
            echo "✅ Migrations completed"
        fi

        ############################################################################
        # Storage Link
        ############################################################################
        if [ "${AUTORUN_LARAVEL_STORAGE_LINK:=true}" = "true" ]; then
            echo "🔗 Creating storage symlink..."
            php "$APP_BASE_DIR/artisan" storage:link --force
            echo "✅ Storage link created"
        fi

        ############################################################################
        # Laravel Caching
        ############################################################################
        if [ "${AUTORUN_LARAVEL_CONFIG_CACHE:=true}" = "true" ]; then
            echo "⚡ Caching Laravel configuration..."
            php "$APP_BASE_DIR/artisan" config:cache
            echo "✅ Configuration cached"
        fi

        if [ "${AUTORUN_LARAVEL_ROUTE_CACHE:=true}" = "true" ]; then
            echo "🛣️  Caching Laravel routes..."
            php "$APP_BASE_DIR/artisan" route:cache
            echo "✅ Routes cached"
        fi

        if [ "${AUTORUN_LARAVEL_VIEW_CACHE:=true}" = "true" ]; then
            echo "👁️  Caching Laravel views..."
            php "$APP_BASE_DIR/artisan" view:cache
            echo "✅ Views cached"
        fi

        if [ "${AUTORUN_LARAVEL_EVENT_CACHE:=true}" = "true" ]; then
            echo "📡 Caching Laravel events..."
            php "$APP_BASE_DIR/artisan" event:cache
            echo "✅ Events cached"
        fi

        ############################################################################
        # Laravel Octane
        ############################################################################
        if [ "${AUTORUN_LARAVEL_OCTANE}" = "true" ]; then
            echo "🎯 Starting Laravel Octane server..."

            # Check if Octane is installed
            if php "$APP_BASE_DIR/artisan" list | grep -q "octane:"; then
                echo "🔧 Laravel Octane detected, starting server..."

                # Start Octane in background
                php "$APP_BASE_DIR/artisan" octane:start \
                    --server="$OCTANE_SERVER" \
                    --host="$OCTANE_HOST" \
                    --port="$OCTANE_PORT" &

                OCTANE_PID=$!
                echo "✅ Laravel Octane started with PID: $OCTANE_PID (Server: $OCTANE_SERVER, Host: $OCTANE_HOST, Port: $OCTANE_PORT)"

                # Store PID for potential cleanup
                echo "$OCTANE_PID" > /tmp/octane.pid

                # Give Octane a moment to start
                sleep 2

                # Verify Octane is running
                if kill -0 "$OCTANE_PID" 2>/dev/null; then
                    echo "🎉 Laravel Octane is running successfully!"
                else
                    echo "⚠️  Laravel Octane failed to start properly"
                fi
            else
                echo "⚠️  Laravel Octane not installed, skipping Octane startup"
            fi
        fi

        echo "✨ Laravel automations with Octane completed!"
    else
        echo "ℹ️  Laravel automations disabled or artisan file not found"
    fi
fi