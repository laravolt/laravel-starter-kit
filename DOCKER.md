# Docker

Two compose stacks ship with the starter kit. Both use the [laravoltdev/image](https://hub.docker.com/r/laravoltdev/image) images, built once in CI and published to Docker Hub.

| Stack | Purpose | Image | Command |
| --- | --- | --- | --- |
| `docker-compose.dev.yml` | Mounted-source dev sandbox | `laravoltdev/image:php8.5-dev` (pulled, not built) | `docker compose -f docker-compose.dev.yml up -d` |
| `docker-compose.prod.yml` | Baked production demo | built on `laravoltdev/image:php8.5-prod` | `docker compose -f docker-compose.prod.yml up --build -d` |

## Development

The dev stack pulls `laravoltdev/image:php8.5-dev` and mounts your working tree on `/var/www/html`. Nothing is built on your machine, and the image runs natively on Intel and Apple Silicon. FrankenPHP serves the app on `:8080`, and Vite is reachable on `:5173`. The image includes Bun, plus Xdebug, which is off until you set `XDEBUG_MODE=debug`.

```bash
docker compose -f docker-compose.dev.yml up -d
docker compose -f docker-compose.dev.yml exec app composer install
docker compose -f docker-compose.dev.yml exec app php artisan migrate
docker compose -f docker-compose.dev.yml exec app bun install
docker compose -f docker-compose.dev.yml exec app bun run dev
# Open http://localhost:8080
```

## Production

The prod image builds the Composer vendor and Vite assets in dedicated stages and then copies them into a FrankenPHP runtime. SQLite is used by default for portability; uncomment the `postgres` service block in `docker-compose.prod.yml` (and switch your `.env` to `DB_CONNECTION=pgsql`) to add a real database.

```bash
docker compose -f docker-compose.prod.yml up --build -d
# Open http://localhost:8090
```

The image runs the Caddy/FrankenPHP combo on port `:8080`; the compose file binds it to `127.0.0.1:8090` on the host so you can put your own reverse proxy in front.

Production forces https URLs (`nunomaduro/essentials`). The compose file sets `APP_FORCE_HTTPS: "false"` so login works on plain http at `localhost:8090`. Behind a TLS proxy, set it to `"true"` and use an https `APP_URL`.

## Notes

- PHP 8.5 is required (matches `composer.json`).
- The dev stack uses `CACHE_STORE=array`. Laravolt 8.0.1+ and laravolt/avatar 8.0.1+ also work with `database`, `file` and `redis` caches.
- Frontend assets are built with [Bun](https://bun.sh/) from `bun.lock`, both in the dev image and in the prod Dockerfile's `oven/bun` stage.
- The dev stack mounts the host's working tree, so changes are picked up live; the prod stack bakes everything into the image and exposes only `storage/`, `bootstrap/cache/`, and `database/` as named volumes.
