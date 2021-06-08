#!/bin/sh

ROOT_PASSWORD='root'

while ! systemctl status mariadb; do
    sleep 1
done

expect -c "
    spawn /usr/bin/mysql_secure_installation
    sleep 1
    send \"\r\"
    sleep 1
    send \"\r\"
    sleep 1
    send \"${ROOT_PASSWORD}\r\"
    sleep 1
    send \"${ROOT_PASSWORD}\r\"
    sleep 1
    send \"\r\"
    sleep 1
    send \"\r\"
    sleep 1
    send \"\r\"
    sleep 1
    send \"\r\"
    sleep 1
    send \"n\r\"
    sleep 1
    send \"\r\"
    sleep 1
    expect eof
"

# Remove self
rm /usr/local/sbin/init-mariadb.sh
