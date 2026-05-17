# syntax=docker/dockerfile:1
# Laravolt v7 starter-kit — dev container.
# PHP CLI + Composer + Node for fast iteration with the source tree mounted.

FROM php:8.4-cli-alpine

WORKDIR /app

RUN apk add --no-cache \
        bash \
        git \
        curl \
        nodejs \
        npm \
        sqlite \
        sqlite-dev \
        libpng-dev \
        libzip-dev \
        icu-dev \
        oniguruma-dev \
    && docker-php-ext-install \
        bcmath \
        gd \
        pdo_sqlite \
        zip \
        intl \
        opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

EXPOSE 8000 5173

# Compose mounts the working tree onto /app; install + migrate + serve on boot.
CMD ["bash", "-lc", "\
    composer install --no-interaction --prefer-dist && \
    npm install && \
    [ -f .env ] || cp .env.example .env && \
    php artisan key:generate --force || true && \
    mkdir -p database && touch database/database.sqlite && \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=8000 \
"]
