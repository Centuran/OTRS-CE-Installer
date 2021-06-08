#
# Apache-related functions
#

is_apache_installed() {
    apt-get update > /dev/null # TODO: should be executed once at the start of installation
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
    ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime # to skip interactive installation
    apt-get install -y apache2  2>&1 | frame_output

    return "${PIPESTATUS[0]}"
}

#
# MariaDB-related functions
#

is_mariadb_installed() {
    if dpkg -s mariadb-server &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_mariadb_version() {
    echo $(dpkg -s mariadb-server | grep '^Version' | sed 's/^.*\?:\s\+//')
}

install_mariadb() {
    local ROOT_PASSWORD=$(generate_password)

    (
        apt-get install -y mariadb-server 2>&1
        /etc/init.d/mysql start 2>&1
        /etc/init.d/mysql enable  2>&1
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

#
# Other functions
#

install_perl_module() {
    local MODULE=$1
    PKG=`echo $MODULE | sed 's/::/-/g;s/[A-Z]/\L&/g'`
    PKG="lib$PKG-perl"

    if apt-get install -y ${PKG} &> /dev/null; then
        return 0
    else
         if ! cpanm --version &> /dev/null < /dev/null; then
            if ! apt-get install -y 'cpanminus' &> /dev/null; then
                # TODO: Handle error
                return 1
            fi
            apt-get install -y "build-essential" &> /dev/null

        fi
        if cpanm "${MODULE}" &> /dev/null < /dev/null; then
            return 0
        else
            return 1
        fi
    fi

}
