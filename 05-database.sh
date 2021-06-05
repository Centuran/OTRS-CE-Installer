# TODO: Check server configuration (max_allowed_packet, etc.)

if [ -z "${MARIADB_ROOT_PASSWORD}" ]; then
    echo -n "Enter MariaDB root password: "
    MARIADB_ROOT_PASSWORD=$(read_password)
    echo
    echo

    # TODO: If MariaDB was installed earlier in the process, maybe inform the
    # user that they can read the password somewhere above
fi

# TODO: Move to initial config file
DATABASE_HOST='localhost'
DATABASE='otrs'
DATABASE_USER='otrs'
DATABASE_PASSWORD=$(generate_password)

echo -n "Creating database and database user... "

# TODO: https://gitlab.dev.sidnet.info/centuran/otrs-community-edition/-/blob/66b130841735590cfc69bf8afcc69b08207d543f/Kernel/Modules/Installer.pm#L503
#mysql -u root -p"${MARIADB_ROOT_PASSWORD}" &>/dev/null <<END
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<END
    CREATE DATABASE \`${DATABASE}\` CHARSET utf8;
    GRANT ALL PRIVILEGES ON \`${DATABASE}\`.*
        TO \`${DATABASE_USER}\`@\`${DATABASE_HOST}\`
        IDENTIFIED BY '${DATABASE_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
END

if [ $? = 0 ]; then
    print_check_result "created" 1
else
    print_check_result "failed" 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo -n "Running database creation scripts... "

cat "${INSTALL_DIR}/scripts/database/otrs-schema.mysql.sql" \
    "${INSTALL_DIR}/scripts/database/otrs-initial_insert.mysql.sql" \
    "${INSTALL_DIR}/scripts/database/otrs-schema-post.mysql.sql" \
    | mysql -h "${DATABASE_HOST}" -u "${DATABASE_USER}" \
        -p"${DATABASE_PASSWORD}" "${DATABASE}" &>/dev/null

if [ $? = 0 ]; then
    print_check_result "completed" 1
else
    print_check_result "failed" 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo
print_check_result 'Database was created successfully.' 1
echo
