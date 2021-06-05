echo -n 'Setting file permissions... '

if "${INSTALL_DIR}/bin/otrs.SetPermissions.pl" &> /dev/null; then
    print_check_result 'completed' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo
print_check_result 'File permissions set successfully.' 1
echo
