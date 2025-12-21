#!/bin/sh
set -e

if [ "$APP_ENV" = "dev" ]; then
    echo "Installing Composer dependencies..."
    if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
        composer install --no-interaction --prefer-dist
    fi

    echo "Ensuring proper permissions..."
    mkdir -p var/cache var/log

    if [ -f "bin/console" ]; then
        php bin/console cache:clear --no-warmup || true
        php bin/console cache:warmup || true
    fi
fi

exec "$@"
