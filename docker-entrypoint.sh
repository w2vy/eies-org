#!/bin/bash
set -e

# Ensure socket directory is accessible
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chmod 755 /run/mysqld

# Initialize MediaWiki database if needed (use marker file)
if [ ! -f "/var/lib/mysql/.mw_initialized" ]; then
    echo "Initializing MySQL for MediaWiki..."

    # Start MySQL temporarily for setup
    mysqld_safe --skip-networking &

    # Wait for MySQL to start
    echo "Waiting for MySQL to start..."
    for i in {1..30}; do
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done

    # Create database and user
    echo "Creating database and user..."
    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS mwnew;
        CREATE USER IF NOT EXISTS 'mediawiki'@'localhost' IDENTIFIED WITH mysql_native_password BY 'nouseme';
        GRANT ALL PRIVILEGES ON mwnew.* TO 'mediawiki'@'localhost';
        FLUSH PRIVILEGES;
EOSQL

    # Import database dump if it exists
    if [ -f "/docker-entrypoint-initdb.d/mwnew.sql" ]; then
        echo "Importing database..."
        mysql -u root mwnew < /docker-entrypoint-initdb.d/mwnew.sql
    fi

    # Stop temporary MySQL
    mysqladmin -u root shutdown

    # Create marker file
    touch /var/lib/mysql/.mw_initialized

    echo "MySQL initialization complete."
fi

# Generate LocalSettings.php from template (update DB server to localhost)
if [ -f "/var/www/html/LocalSettings.php.template" ]; then
    sed 's/\$wgDBserver = "db";/\$wgDBserver = "localhost";/' \
        /var/www/html/LocalSettings.php.template > /var/www/html/LocalSettings.php
    chown www-data:www-data /var/www/html/LocalSettings.php
fi

exec "$@"
