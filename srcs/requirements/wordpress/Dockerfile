FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-curl \
    php83-gd \
    php83-intl \
    php83-mbstring \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-opcache \
    php83-session \
    wget \
    netcat-openbsd \
    curl

RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress && chown -R nobody:nobody /var/www/wordpress
RUN mkdir -p /run/php83

COPY conf/fpm.conf /etc/php83/php-fpm.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/www/wordpress"]

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
