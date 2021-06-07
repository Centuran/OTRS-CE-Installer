echo -n 'Starting daemon process... '

if runuser -u otrs "${INSTALL_DIR}/bin/otrs.Daemon.pl" 'start' &> /dev/null;
then
    print_check_result 'started' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo
print_check_result 'Daemon process started.' 1
echo
