ARG PHP_VERSION=8.4
ARG PHP_EXTENSIONS
ARG PECL_EXTENSIONS
ARG APK_PACKAGES

# Use Alpine-based PHP image
FROM php:${PHP_VERSION}-cli-alpine AS base

ARG PHP_EXTENSIONS
ARG PECL_EXTENSIONS
ARG APK_PACKAGES

# Install system dependencies using apk
RUN apk add --no-cache \
    curl \
    ca-certificates \
    libcap \
    bash \
    ${APK_PACKAGES}

# Install mlocati's PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install FrankenPHP static binary
RUN curl -L https://github.com/dunglas/frankenphp/releases/download/v1.3.4/frankenphp-linux-x86_64 -o /usr/local/bin/frankenphp \
    && chmod +x /usr/local/bin/frankenphp \
    && setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp

# Install PHP extensions
RUN if [ -n "${PHP_EXTENSIONS}" ]; then \
        install-php-extensions ${PHP_EXTENSIONS}; \
    fi

RUN if [ -n "${PECL_EXTENSIONS}" ]; then \
        install-php-extensions ${PECL_EXTENSIONS}; \
    fi

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

WORKDIR /app

# ==========================================
# Development Stage
# ==========================================
FROM base AS dev

RUN install-php-extensions xdebug

COPY docker/frankenphp/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY docker/frankenphp/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Create Caddy config directory
RUN mkdir -p /etc/caddy
COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

# Copy and set up entrypoint script
COPY docker/frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p /app/var /app/vendor /app/public && \
    chown -R www-data:www-data /app

EXPOSE 80 443 2019

# Use the entrypoint script!
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--watch"]

# ==========================================
# Production Stage
# ==========================================
FROM base AS prod

COPY docker/frankenphp/opcache.prod.ini /usr/local/etc/php/conf.d/opcache.ini

# Create Caddy config directory
RUN mkdir -p /etc/caddy
COPY docker/frankenphp/Caddyfile.prod /etc/caddy/Caddyfile

# Copy application files
COPY --chown=www-data:www-data . /app

# Install production dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction \
    && composer dump-autoload --optimize --classmap-authoritative \
    && composer clear-cache

# Warm up cache and set permissions
RUN php bin/console cache:warmup --env=prod \
    && chown -R www-data:www-data /app/var

# Remove sensitive files
RUN rm -rf .env.local .env.*.local docker/ tests/

USER www-data

EXPOSE 80 443

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
