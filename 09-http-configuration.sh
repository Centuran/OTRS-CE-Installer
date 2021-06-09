echo -n 'Checking if mod_perl is installed... '

if is_mod_perl_installed; then
    print_check_result 'installed' 1
else
    print_check_result 'not installed' 0

    echo
    echo 'Installing mod_perl...'
    echo

    if install_mod_perl; then
        echo
        print_check_result 'mod_perl installed.' 1
        echo
    else
        echo
        print_check_result 'mod_perl installation failed.' 0
        echo
        # TODO: Show error
        exit 1
    fi
fi

echo 'Checking if other required modules are enabled...'

for MODULE in deflate filter headers version; do
    echo -n " • Checking for \"${MODULE}\"... "

    if apachectl -M 2> /dev/null | grep "^ ${MODULE}_module " &> /dev/null; then
        print_check_result 'enabled' 1
    else
        print_check_result 'not found' 0

        echo -n "   Enabling module \"${MODULE}\"..."
        if enable_apache_mod ${MODULE}; then
            print_check_result " enabled" 1
        else
            print_check_result " failed" 0
            echo
            # TODO: Show error
            exit 1
        fi
    fi
done
echo

echo -n 'Adding web application configuration... '

if ln -s "${INSTALL_DIR}/scripts/apache2-httpd.include.conf" \
    $(get_apache_config_dir)/zzz_otrs.conf;
then
    print_check_result 'added' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo -n 'Restarting HTTP server... '

if restart_apache; then
    print_check_result 'restarted' 1
else
    print_check_result 'failed' 0
fi

echo
print_check_result 'HTTP server configured successfully.' 1
echo
