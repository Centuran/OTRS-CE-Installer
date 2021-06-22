#
# MariaDB-related functions
#

do_mariadb_secure_installation() {
    echo -e "\n\n\n${ROOT_PASSWORD}\n${ROOT_PASSWORD}\n\n\n\nn\n\n" \
        | /usr/bin/mysql_secure_installation 2>&1
}
