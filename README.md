## Install using Docker

- Git Clone
- Copy Example files and modify as needed:
    - `.env.example` to `.env`
    - `docker/.env.example` to `docker/.env`
    - `docker/.envs/php-ini.example.env` to `docker/.envs/php-ini.example.env`
    - `docker/.envs/web.example.env` to `docker/.envs/web.example.env`
- If need jaeger, append `:docker-compose.jaeger.yml` in `COMPOSE_FILE` in `docker/.env` file.
- In `docker` directory, run `docker compose build`
- Run `docker compose run --rm composer install`
- Run `docker compose up -d`

## Usage

- First visit the laravel app in your browser.
- Visit the jaeger page (Usually http://localhost:16686) and see the graphs & traces.
