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
    apt-get update > /dev/null # TODO: should be executed once at the start of installation
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

install_mariadb() {
    local ROOT_PASSWORD=$(generate_password)

    (
        apt-get install -y mariadb-server 2>&1
        service mysql start 2>&1
        service mysql enable 2>&1
        echo -e "\n\n${ROOT_PASSWORD}\n${ROOT_PASSWORD}\n\n\n\nn\n\n" \
            | /usr/bin/mysql_secure_installation 2>&1
    ) | frame_output

    local STATUS=${PIPESTATUS[0]}

    if [ ${STATUS} = 0 ]; then
        # Set variable so that the user doesn't need to enter this password
        # for database creation step
        MARIADB_ROOT_PASSWORD="${ROOT_PASSWORD}"
        echo
        print_notice "The installer has set the MariaDB
            ${COLOR_NOTICE_BOLD}root${COLOR_NOTICE} user password to
            \"${COLOR_NOTICE_BOLD}${ROOT_PASSWORD}${COLOR_NOTICE}\" (without the
            quotes). Please keep this password safe or change it."
        # TODO: Tell the user how to change the password or what docs to read
        echo

        print_centered "Press $(style_key Enter) to proceed." 80
        echo

        expect_enter
    fi

    return "${STATUS}"
}