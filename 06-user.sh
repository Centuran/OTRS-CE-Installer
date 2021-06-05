echo -n 'Creating system user... '

if useradd -d "${INSTALL_DIR}" -c 'OTRS CE user' "${SYSTEM_USER}" &> /dev/null;
then
    print_check_result "created" 1
else
    print_check_result "failed" 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo -n 'Adding user to HTTP server group... '

if usermod -G $(get_apache_group) "${SYSTEM_USER}" &> /dev/null; then
    print_check_result "added" 1
else
    print_check_result "failed" 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo
print_check_result 'User was created successfully.' 1
echo
