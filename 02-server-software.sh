# Global variables set:
#   - DATABASE_SERVER
#   - DATABASE_SERVER_NOT_INSTALLED
#   - DATABASE_SERVER_VERSION
#   - HTTP_SERVER
#   - HTTP_SERVER_NOT_INSTALLED
#   - HTTP_SERVER_VERSION
#   - MARIADB_ROOT_PASSWORD

check_http_server() {
    HTTP_SERVER=
    HTTP_SERVER_VERSION=

    if is_apache_installed; then
        HTTP_SERVER='Apache'
        HTTP_SERVER_VERSION=$(get_apache_version)
    fi

    if [ ! -z "${HTTP_SERVER}" ]; then
        print_check_result "${HTTP_SERVER} (${HTTP_SERVER_VERSION})" 1
    else
        HTTP_SERVER_NOT_INSTALLED=1
        STATUS=${STATUS_FAILURE}
        print_check_result "not found" 0
    fi
}

check_database() {
    DATABASE_SERVER=
    DATABASE_SERVER_VERSION=

    if is_mariadb_installed; then
        DATABASE_SERVER='MariaDB'
        DATABASE_SERVER_VERSION=$(get_mariadb_version)
    fi

    if [ ! -z "${DATABASE_SERVER}" ]; then
        print_check_result "${DATABASE_SERVER} (${DATABASE_SERVER_VERSION})" 1
    else
        DATABASE_SERVER_NOT_INSTALLED=1
        STATUS=${STATUS_FAILURE}
        print_check_result 'not found' 0
    fi
}

check() {
    STATUS_OK=0
    STATUS_FAILURE=101

    STATUS=${STATUS_OK}

    echo -n ' • Checking for HTTP server:     '
    check_http_server

    echo -n ' • Checking for database server: '
    check_database

    return ${STATUS}
}

act() {
    if [ "${HTTP_SERVER_NOT_INSTALLED}" = 1 ]; then
        echo
        print_notice "No HTTP server has been found on this system.
            The installer can attempt to fix this and install the Apache HTTP
            server using standard system software repositories."
        echo

        print_centered "Press $(style_key Enter) to install Apache, or
            $(style_key Esc) to exit." 80
        echo

        expect_enter_exit_on_esc

        echo
        echo "Installing Apache..."
        echo

        if install_apache; then
            echo
            print_check_result 'Installation of Apache was successful.' 1
        else
            echo
            print_check_result 'Installation of Apache failed.' 0

            # TODO: Enter to repeat, Esc to exit
        fi
    fi

    if [ "${DATABASE_SERVER_NOT_INSTALLED}" = 1 ]; then
        echo
        print_notice "No database server has been found on this system.
            The installer can attempt to fix this and install the MariaDB server
            using standard system software repositories."
        echo

        print_centered "Press $(style_key Enter) to install MariaDB, or
            $(style_key Esc) to exit." 80
        echo

        expect_enter_exit_on_esc

        echo
        echo "Installing MariaDB..."
        echo

        if install_mariadb; then
            echo
            print_check_result 'Installation of MariaDB was successful.' 1
        else
            echo
            print_check_result 'Installation of MariaDB failed.' 0

            # TODO: Enter to repeat, Esc to exit
        fi
    fi
}

while ! check; do
    act

    echo
    echo "Repeating checks..."
    echo
done

echo
print_check_result 'Required software check successful.' 1
echo
