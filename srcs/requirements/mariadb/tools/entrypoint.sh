#!/bin/sh
set -e

read_secret() {
    local f="$1"
    [ -f "$f" ] && cat "$f" || { echo "ERROR: secret '$f' missing" >&2; exit 1; }
}

echo "[db] Reading secrets..."
DB_PASSWORD=$(read_secret "${MYSQL_PASSWORD_FILE}")
DB_ROOT_PASSWORD=$(read_secret "${MYSQL_ROOT_PASSWORD_FILE}")
echo "[db] Secrets OK"

echo "[db] Writing healthcheck config..."
printf '[client]\nuser=root\npassword=%s\nsocket=/run/mysqld/mysqld.sock\n' "${DB_ROOT_PASSWORD}" > /var/lib/mysql/.healthcheck.cnf
chown mysql:mysql /var/lib/mysql/.healthcheck.cnf
chmod 600 /var/lib/mysql/.healthcheck.cnf

# Always fix ownership — survives across restarts and ownership changes
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[db] First run — initialising..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    echo "[db] mysql_install_db done"

    mysqld --user=mysql --skip-networking &
    TEMP_PID=$!
    echo "[db] Temp mysqld started, PID=$TEMP_PID"

    for i in $(seq 1 30); do
        if [ -S /run/mysqld/mysqld.sock ]; then
            echo "[db] Socket ready!"
            break
        fi
        echo "[db] Waiting for socket... ($i)"
        sleep 1
    done

    echo "[db] Running SQL..."
    mysql --socket=/run/mysqld/mysqld.sock << SQLEOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQLEOF

    echo "[db] SQL done, shutting down temp mysqld..."
    kill "$TEMP_PID"
    wait "$TEMP_PID" 2>/dev/null || true
    echo "[db] Init complete."

else
    echo "[db] Data directory exists, skipping init."
fi

echo "[db] Starting mysqld..."
exec mysqld --user=mysql
