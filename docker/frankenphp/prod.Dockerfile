# syntax=docker/dockerfile:1
# Laravolt v7 starter-kit — production container.
# Multi-stage: composer install + bun build, then bake into laravoltdev/image.

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

FROM oven/bun:1-alpine AS assets
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile
COPY resources ./resources
COPY vite.config.js ./
RUN bun run build

FROM laravoltdev/image:php8.5-prod AS runtime

USER root

COPY --from=vendor /app /var/www/html
COPY --from=assets /app/public/build /var/www/html/public/build

RUN mkdir -p \
        /var/www/html/storage/app/public \
        /var/www/html/storage/framework/cache/data \
        /var/www/html/storage/framework/sessions \
        /var/www/html/storage/framework/views \
        /var/www/html/storage/logs \
        /var/www/html/bootstrap/cache \
        /var/www/html/database \
    && touch /var/www/html/database/database.sqlite \
    && chown -R www-data:www-data \
        /var/www/html/storage \
        /var/www/html/bootstrap/cache \
        /var/www/html/database

USER www-data

ENV AUTORUN_ENABLED=true
ENV AUTORUN_LARAVOLT_LINK=true
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV LOG_CHANNEL=stderr
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/var/www/html/database/database.sqlite
ENV CACHE_STORE=array
ENV SESSION_DRIVER=database
ENV QUEUE_CONNECTION=sync
