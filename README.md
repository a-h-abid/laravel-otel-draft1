## Install using Docker

- Git Clone
- Copy Example files and modify as needed:
    - `.env.example` to `.env`
        - Set `DB_CONNECTION` to `sqlite` or `mysql` and set other params as needed.
    - `docker/.env.example` to `docker/.env`
        - If need jaeger, append `:docker-compose.jaeger.yml` in `COMPOSE_FILE` in `docker/.env` file.
    - `docker/.envs/php-ini.example.env` to `docker/.envs/php-ini.env`
    - `docker/.envs/web.example.env` to `docker/.envs/web.env`
    - `docker/.envs/jaeger.example.env` to `docker/.envs/jaeger.env`
- In `docker` directory,
    - Run `docker compose build`
    - Run `docker compose run --rm app composer install`
    - Run `docker compose run --rm app php artisan migrate`
    - Run `docker compose up -d`

## Usage

- First visit some routes in your browser.
    - http://localhost:8080/
    - http://localhost:8080/users/add
    - http://localhost:8080/users/list
- Visit the jaeger page (Usually http://localhost:16686) and see the graphs & traces.
