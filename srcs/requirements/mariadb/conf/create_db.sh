#!/bin/sh

# . ../../../.env
# echo "DB Name: ${DB_NAME}"
# echo "DB Root: $DB_ROOT"
# echo "DB User: ${DB_USER}"
# echo "DB Password: ${DB_PASS}"
source .env
set -e

# Log with colored prefix :)
function log()
{
    echo -e "\e[33minception-mariadb\e[0m | $@"
}

# Run this if the container is unprepared
if [ ! -e /etc/.inception_firstrun ]; then
    # Allow outside connections to the database server
    log 'Adjusting server configuration'
    cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0

EOF

    # Mark the container as prepared
    touch /etc/.inception_firstrun
fi

# Run this if the database volume is unpopulated
if [ ! -e /var/lib/mysql/.inception_firstrun ]; then
    # Refuse to continue if any environment variable is missing
    # if [ -z ${DB_ROOT} ]; then
    #     log 'Please set MYSQL_ROOT_PASSWORD, refusing to continue'
    #     exit 1
    # fi
    # if [ -z ${DB_USER} ]; then
    #     log 'Please set DB_USER, refusing to continue'
    #     exit 1
    # fi
    # if [ -z ${DB_PASS} ]; then
    #     log 'Please set MYSQL_PASSWORD, refusing to continue'
    #     exit 1
    # fi
    # if [ -z ${DB_NAME} ]; then
    #     log 'Please set DB_NAME, refusing to continue'
    #     exit 1
    # fi

    # Install the database
    log 'Installing database'
    mysql_install_db \
        --auth-root-authentication-method=socket \
        --datadir=/var/lib/mysql \
        --skip-test-db \
        --user=mysql \
        --group=mysql >/dev/null

    # Start the server as a background process and wait for it to be ready
    log 'Bringing up temporary server'
    mysqld_safe &
    mysqladmin ping -u root --silent --wait >/dev/null

    # Perform database and user initialization
    log "Performing initial configuration"
    cat << EOF | mysql --protocol=socket -u root -p=

CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$DB_ROOT';
FLUSH PRIVILEGES;

EOF

    # Shutdown the background server
    log 'Shutting down temporary server'
    mysqladmin shutdown

    # Mark the database volume as populated
    touch /var/lib/mysql/.inception_firstrun
fi

# Start the server as the only process in the container
log 'Starting server'
exec mysqld_safe


# CREATE DATABASE IF NOT EXISTS ${DB_NAME};
# CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
# GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
# GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '${DB_ROOT}';
# FLUSH PRIVILEGES;