if [ ! -e "${INSTALL_DIR}" ]; then
    echo -n "Creating installation directory... "

    if mkdir "${INSTALL_DIR}"; then
        print_check_result "created" 1
    else
        print_check_result "failed" 0
        # TODO: Explain to user, enter to exit
        exit 1
    fi
fi

if ! which bzip2 &> /dev/null; then
    echo
    echo "Installing bzip2..."
    echo
    
    if install_bzip2; then
        echo
        print_check_result 'Installation of bzip2 was successful.' 1
        echo
    else
        echo
        print_check_result 'Installation of bzip2 failed.' 0
        echo
        # TODO: Explain to user, enter to exit
        exit 1
    fi
fi

echo -n "Extracting ((OTRS)) Community Edition files... "

if tar jxf "${SCRIPT_DIR}"/otrs-community-edition-*.tar.bz2 \
    -C "${INSTALL_DIR}" --strip-components=1 2>&1;
then
    print_check_result "extracted" 1
else
    print_check_result "failed" 0
    # TODO: Explain to user, show tar error
    exit 1
fi

echo
print_check_result 'Files extracted successfully.' 1
echo
