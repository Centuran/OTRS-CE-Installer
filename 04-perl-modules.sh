missing_modules() {
    local LINE

    perl "${INSTALL_DIR}/bin/otrs.CheckModules.pl" 2> /dev/null | \
        grep 'Not installed' | \
        while read LINE; do
            # Extract just the module name
            MODULE=$(echo "${LINE}" | \
                sed 's/^\s*.\s*\([^.]\+\).*$/\1/;s/^\[\S*\s*.\s*//g')

            if echo "${LINE}" | grep -i 'optional' &> /dev/null; then
                # Optional module -- check if we need it
                if [ "${MODULE}" = 'DBD::mysql' ] && \
                    [ "${DATABASE_SERVER}" = 'MariaDB' ]
                then
                    :           # Do nothing (add DBD::mysql to the list)
                else
                    continue    # Continue loop (ignore optional module)
                fi
            fi

            printf "${MODULE}\n"
        done
}

echo 'Checking for missing Perl modules...'

MISSING_MODULES=$(missing_modules)

while [ ! -z "${MISSING_MODULES}" ]; do
    echo
    printf "${MISSING_MODULES}\n" | while read MODULE; do
        echo -n " • Installing ${MODULE}... "
        if install_perl_module "${MODULE}"; then
            print_check_result "installed" 1
        else
            print_check_result "failed" 0
            # TODO: Explain to user, show error
            exit 1
        fi
    done

    MISSING_MODULES=$(missing_modules)
done

echo
print_check_result 'All required Perl modules are installed.' 1
echo
