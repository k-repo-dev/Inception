#!/bin/sh
set -e

read_secret() {
    local f="$1"
    [ -f "$f" ] && cat "$f" || { echo "ERROR: secret '$f' missing" >&2; exit 1; }
}

echo "[wp] Reading secrets..."
DB_PASSWORD=$(read_secret "${MYSQL_PASSWORD_FILE}")
WP_ADMIN_PASSWORD=$(read_secret "${WP_ADMIN_PASSWORD_FILE}")
WP_USER_PASSWORD=$(read_secret "${WP_USER_PASSWORD_FILE}")
echo "[wp] Secrets OK"

WP_DIR="/var/www/wordpress"
mkdir -p "$WP_DIR"

if [ ! -f "$WP_DIR/wp-login.php" ]; then
    echo "[wp] Downloading WordPress..."
    php -d memory_limit=256M /usr/local/bin/wp core download \
        --path="$WP_DIR" --locale=en_US --allow-root
fi

if [ ! -f "$WP_DIR/wp-config.php" ]; then
    echo "[wp] Creating wp-config.php..."
    php -d memory_limit=256M /usr/local/bin/wp config create \
        --path="$WP_DIR" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

if ! php -d memory_limit=256M /usr/local/bin/wp core is-installed \
    --path="$WP_DIR" --allow-root 2>/dev/null; then
    echo "[wp] Installing WordPress..."
    php -d memory_limit=256M /usr/local/bin/wp core install \
        --path="$WP_DIR" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "[wp] Creating subscriber user..."
    php -d memory_limit=256M /usr/local/bin/wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="$WP_DIR" \
        --allow-root

    echo "[wp] WordPress installed."
fi

chown -R nobody:nobody "$WP_DIR"

echo "[wp] Starting php-fpm..."
exec php-fpm83 -F
