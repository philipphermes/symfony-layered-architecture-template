ARG FRANKENPHP_VERSION=1.3.4
ARG PHP_VERSION=8.4

# ==========================================
# Base Stage
# ==========================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-alpine AS base

ARG PHP_EXTENSIONS="intl pdo_pgsql zip opcache sodium"
ARG PECL_EXTENSIONS=""
ARG APK_PACKAGES=""

# Install system dependencies
RUN apk add --no-cache \
    curl \
    ca-certificates \
    bash \
    git \
    unzip \
    ${APK_PACKAGES}

# Install mlocati's PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install PHP extensions
RUN if [ -n "${PHP_EXTENSIONS}" ]; then \
        install-php-extensions ${PHP_EXTENSIONS}; \
    fi

RUN if [ -n "${PECL_EXTENSIONS}" ]; then \
        install-php-extensions ${PECL_EXTENSIONS}; \
    fi

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

WORKDIR /app

# ==========================================
# Development Stage
# ==========================================
FROM base AS dev

# Install Xdebug for development
RUN install-php-extensions xdebug

# Copy PHP configuration
COPY docker/frankenphp/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY docker/frankenphp/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Create Caddy config directory
RUN mkdir -p /etc/caddy
COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

# Don't copy application files - they'll be mounted as volumes in docker-compose

EXPOSE 80 443 2019

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--watch"]

# ==========================================
# Production Stage
# ==========================================
FROM base AS prod

# Create Caddy config directory
RUN mkdir -p /etc/caddy
COPY docker/frankenphp/Caddyfile.prod /etc/caddy/Caddyfile

# Copy composer files first for better layer caching
COPY --chown=www-data:www-data composer.json composer.lock symfony.lock /app/

# Install production dependencies (this layer caches until composer files change)
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction \
    && composer clear-cache

# Copy application files (this invalidates cache when your code changes)
COPY --chown=www-data:www-data . /app

# Fix ownership of vendor directory before switching user
RUN chown -R www-data:www-data /app/vendor

# Generate optimized autoloader with full application code
RUN composer dump-autoload --optimize --classmap-authoritative

# Warm up Symfony cache first
RUN APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear \
    && APP_ENV=prod APP_DEBUG=0 php bin/console cache:warmup \
    && chown -R www-data:www-data /app/var

# Verify preload file exists before enabling opcache preload
RUN if [ ! -f /app/config/preload.php ]; then \
        echo "Warning: preload.php not found, creating empty one"; \
        mkdir -p /app/config && \
        echo "<?php" > /app/config/preload.php; \
    fi

# Copy opcache config after cache is warmed
COPY docker/frankenphp/opcache.prod.ini /usr/local/etc/php/conf.d/opcache.ini

# Create Caddy data directory and set permissions
RUN mkdir -p /data/caddy && \
    chown -R www-data:www-data /data/caddy && \
    chown -R www-data:www-data /app

# Verify the application works
RUN php -v && php -m

# Stay as root - FrankenPHP handles security internally
# Preload requires running as root with opcache.preload_user set

EXPOSE 80 443

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
