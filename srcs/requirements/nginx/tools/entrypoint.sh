#!/bin/sh
set -e

SSL_DIR="/etc/nginx/ssl"
CERT="$SSL_DIR/inception.crt"
KEY="$SSL_DIR/inception.key"

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "[nginx] Generating self-signed TLS certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY" \
        -out "$CERT" \
        -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Hive/CN=${DOMAIN_NAME}"
    echo "[nginx] Certificate generated."
fi

echo "[nginx] Configuring domain..."
sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/" /etc/nginx/nginx.conf

echo "[nginx] Starting nginx..."
exec nginx -g 'daemon off;'
