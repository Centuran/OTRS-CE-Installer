#
# Apache-related functions
#

is_apache_installed() {
    if apache2 -v 2> /dev/null | grep 'Apache' &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_apache_group() {
    echo 'www-data'
}

get_apache_version() {
    echo $(apache2 -v | grep 'Apache/' | sed 's/^.*\?Apache\/\([^ ]\+\).*$/\1/')
}

install_apache() {
    apt-get update > /dev/null
    ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime # to skip interactive installation
    apt-get install -y apache2  2>&1 | frame_output

    return "${PIPESTATUS[0]}"
}

#
# MariaDB-related functions
#

is_mariadb_installed() {
    if apt-cache show mariadb-server &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_mariadb_version() {
    echo $(apt-cache show mariadb-server | grep '^Version' | sed 's/^.*\?:\s\+//')
}