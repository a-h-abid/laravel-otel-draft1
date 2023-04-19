FROM docker.io/library/php:8.2-apache

LABEL maintainer="Ahmedul Haque Abid <a_h_abid@hotmail.com>"

# Setup docker arguments.
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY="localhost,127.0.0.1"
ARG TIMEZONE="Asia/Dhaka"
ARG COMPOSER_FILE="composer.json"

# Setup some enviornment variables.
ENV TZ="${TIMEZONE}" \
    COMPOSER_VERSION="2.5.5" \
    COMPOSER_HOME="/usr/local/composer" \
    COMPOSER="${COMPOSER_FILE}"

USER root

# Install & manage application dependencies
RUN echo "-- Configure Timezone --" \
        && echo "${TIMEZONE}" > /etc/timezone \
        && rm /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && echo "-- Install/Upgrade APT Dependencies --" \
        && apt update \
        && apt upgrade -y \
        && apt install -V -y --no-install-recommends --no-install-suggests \
            bc \
            curl \
            zip \
            unzip \
    && echo "-- Install PHP Extensions --" \
        && curl -L -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
        && chmod a+x /usr/local/bin/install-php-extensions \
        && sync \
        && install-php-extensions \
            intl \
            opcache \
            pcntl \
            pdo_mysql \
            sockets \
            zip \
            opentelemetry \
            protobuf \
            zlib \
            grpc \
    && echo "--- Setting Up Apache ---" \
        && a2enmod rewrite headers \
    && echo "--- Clean Up ---" \
        && apt clean -y \
        && apt autoremove -y

# PHP Composer Installation & Directory Permissions
RUN curl -L -o /usr/local/bin/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && mkdir -p ${COMPOSER_HOME}/cache \
    && mkdir /run/php \
    && chmod ugo+x /usr/local/bin/composer \
    && composer --version

WORKDIR /var/www/html

# Additional Apache envs
ENV APACHE_VHOST_DOCUMENT_ROOT="/var/www/html/public" \
    APACHE_VHOST_HTTP_PORT="8080" \
    APACHE_VHOST_HTTPS_PORT="8443" \
    APACHE_RUN_USER="www-data" \
    APACHE_RUN_GROUP="www-data" \
    APACHE_VHOST_SERVER_ADMIN="webmaster@example.com" \
    APACHE_VHOST_SERVER_NAME="_" \
    APACHE_VHOST_SSL_CERTIFICATE_FILE="/etc/ssl/certs/default.crt" \
    APACHE_VHOST_SSL_CERTIFICATE_KEY_FILE="/etc/ssl/certs/default.key"

# PHP INI envs
ENV PHP_INI_OUTPUT_BUFFERING=4096 \
    PHP_INI_MAX_EXECUTION_TIME=60 \
    PHP_INI_MAX_INPUT_TIME=60 \
    PHP_INI_MEMORY_LIMIT="256M" \
    PHP_INI_DISPLAY_ERRORS="Off" \
    PHP_INI_DISPLAY_STARTUP_ERRORS="Off" \
    PHP_INI_POST_MAX_SIZE="2M" \
    PHP_INI_FILE_UPLOADS="On" \
    PHP_INI_UPLOAD_MAX_FILESIZE="2M" \
    PHP_INI_MAX_FILE_UPLOADS="2" \
    PHP_INI_ALLOW_URL_FOPEN="On" \
    PHP_INI_ERROR_LOG="" \
    PHP_INI_DATE_TIMEZONE="${TIMEZONE}" \
    PHP_INI_SESSION_SAVE_HANDLER="files" \
    PHP_INI_SESSION_SAVE_PATH="/tmp" \
    PHP_INI_SESSION_USE_STRICT_MODE=0 \
    PHP_INI_SESSION_USE_COOKIES=1 \
    PHP_INI_SESSION_USE_ONLY_COOKIES=1 \
    PHP_INI_SESSION_NAME="APP_SSID" \
    PHP_INI_SESSION_COOKIE_SECURE="On" \
    PHP_INI_SESSION_COOKIE_LIFETIME=0 \
    PHP_INI_SESSION_COOKIE_PATH="/" \
    PHP_INI_SESSION_COOKIE_DOMAIN="" \
    PHP_INI_SESSION_COOKIE_HTTPONLY="On" \
    PHP_INI_SESSION_COOKIE_SAMESITE="" \
    PHP_INI_SESSION_UPLOAD_PROGRESS_NAME="APP_UPLOAD_PROGRESS" \
    PHP_INI_OPCACHE_ENABLE=1 \
    PHP_INI_OPCACHE_ENABLE_CLI=0 \
    PHP_INI_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_INI_OPCACHE_INTERNED_STRINGS_BUFFER=16 \
    PHP_INI_OPCACHE_MAX_ACCELERATED_FILES=100000 \
    PHP_INI_OPCACHE_MAX_WASTED_PERCENTAGE=25 \
    PHP_INI_OPCACHE_USE_CWD=0 \
    PHP_INI_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_INI_OPCACHE_REVALIDATE_FREQ=0 \
    PHP_INI_OPCACHE_SAVE_COMMENTS=0 \
    PHP_INI_OPCACHE_ENABLE_FILE_OVERRIDE=1 \
    PHP_INI_OPCACHE_MAX_FILE_SIZE=0 \
    PHP_INI_OPCACHE_FAST_SHUTDOWN=1

ARG UID="1000"
ARG GID="1000"

RUN groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash --gid app app \
    && chown -R app:app . ${COMPOSER_HOME} /etc/apache2/sites-available/ /run/apache2 /run/php /run/lock/apache2 /var/log/apache2

COPY ./docker/app/php/php.ini /usr/local/etc/php/conf.d/app-php.ini
COPY --chown=app:app ./composer*.json ./composer*.lock* /var/www/html/

USER app

RUN composer install --no-interaction --no-scripts --no-autoloader --prefer-dist

COPY --chown=app:app ./ /var/www/html/

RUN composer dump-autoload -o

COPY ./docker/app/apache2/ /etc/apache2/

CMD ["apache2-foreground"]
