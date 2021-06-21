#!/bin/sh

ROOT_PASSWORD='root'

if ! which expect; then
    echo "Installing expect..."
    echo

    if install_apt_package expect; then
        echo
        print_check_result 'Installation of expect was successful.' 1
        echo
    else
        echo
        print_check_result 'Installation of expect failed.' 0
        echo
        # TODO: Explain to user, retry?
        exit 1
    fi
fi

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
