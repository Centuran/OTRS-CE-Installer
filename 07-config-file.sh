echo -n 'Copying distribution configuration file... '

if cp "${INSTALL_DIR}/Kernel/Config.pm.dist" \
    "${INSTALL_DIR}/Kernel/Config.pm" &> /dev/null;
then
    print_check_result 'copied' 1
else
    print_check_result 'failed' 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo -n 'Setting configuration options... '

if sed -i "s/\\({DatabaseHost} = \\).*/\\1'${DATABASE_HOST}';/;
    s/\\({Database} = \\).*/\\1'${DATABASE}';/;
    s/\\({DatabaseUser} = \\).*/\\1'${DATABASE_USER}';/;
    s/\\({DatabasePw} = \\).*/\\1'${DATABASE_PASSWORD}';/" \
    "${INSTALL_DIR}/Kernel/Config.pm" 2> /dev/null;
then
    print_check_result 'completed' 1
else
    print_check_result 'failed' 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo
print_check_result 'Configuration file created successfully.' 1
echo
