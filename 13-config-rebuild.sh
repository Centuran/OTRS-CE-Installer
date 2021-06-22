echo -n 'Rebuilding configuration... '

if runuser -u otrs "${INSTALL_DIR}/bin/otrs.Console.pl" 'Maint::Config::Rebuild' &> /dev/null;
then
    print_check_result 'rebuilt' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo
print_check_result 'System configuration rebuilt successfully.' 1
echo
