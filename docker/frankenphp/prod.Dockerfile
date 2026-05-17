# syntax=docker/dockerfile:1
# Laravolt v7 starter-kit — production container.
# FrankenPHP runtime with baked Composer vendor + Vite build assets.

FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
COPY . .
RUN composer install \
        --no-dev \
        --prefer-dist \
        --optimize-autoloader \
        --no-interaction \
        --no-progress

FROM node:24-alpine AS assets
WORKDIR /app
# Use the npm lockfile when present; otherwise fall back to `npm install`.
COPY package.json ./
COPY package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY resources ./resources
COPY vite.config.js ./
RUN npm run build

FROM dunglas/frankenphp:1-php8.4-alpine AS runtime
WORKDIR /app

RUN install-php-extensions \
        bcmath \
        gd \
        pdo_sqlite \
        zip \
        intl \
        opcache

COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

COPY --from=vendor /app /app
COPY --from=assets /app/public/build /app/public/build

RUN mkdir -p \
        storage/app/public \
        storage/framework/cache/data \
        storage/framework/sessions \
        storage/framework/views \
        storage/logs \
        bootstrap/cache \
        database \
    && touch database/database.sqlite \
    && chown -R www-data:www-data storage bootstrap/cache database

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    DB_CONNECTION=sqlite \
    DB_DATABASE=/app/database/database.sqlite \
    CACHE_STORE=array \
    SESSION_DRIVER=database \
    QUEUE_CONNECTION=sync \
    OCTANE_SERVER=frankenphp

EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
