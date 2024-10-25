ARG PHP_VERSION=8.3

FROM dunglas/frankenphp:1.2.5-php${PHP_VERSION}-bookworm

ENV SERVER_NAME=:8080

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN \
    groupadd -g ${GROUP_ID} application && \
    useradd -u ${USER_ID} -g application -m application && \
    setcap -r /usr/local/bin/frankenphp && \
    chown -R application:application /data/caddy && chown -R application:application /config/caddy

RUN install-php-extensions \
	pdo_mysql \
	gd \
	intl \
	zip \
    redis \
    @composer \
    pcntl

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

USER application

EXPOSE 8080
