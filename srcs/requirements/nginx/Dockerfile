FROM alpine:3.20

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    curl

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
