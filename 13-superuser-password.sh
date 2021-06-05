if [ -z "${OTRS_ROOT_PASSWORD}" ]; then
    # TODO: echo "Leave empty to ..."

    while true; do
        echo -n "Enter new password for root@localhost: "
        OTRS_ROOT_PASSWORD=$(read_password)
        echo

        if [ -z "${OTRS_ROOT_PASSWORD}" ]; then
            OTRS_ROOT_PASSWORD=$(generate_password)

            echo
            echo -e "${COLOR_NOTICE}Password set to \"${OTRS_ROOT_PASSWORD}\"" \
                "(without the quotes).${COLOR_NONE}"
            echo
            
            break
        fi

        # TODO: Check password length/strength?

        echo -n "Enter new password again: "
        PASSWORD_REPEATED=$(read_password)
        echo

        if [ "${OTRS_ROOT_PASSWORD}" = "${PASSWORD_REPEATED}" ]; then
            echo
            break
        else
            echo
            echo -ne "${COLOR_ERROR_ACCENTED}Passwords do not match." \
                "${COLOR_NONE}"
            echo "Please try again."
            echo
        fi
    done
fi

echo -n 'Setting password... '

if runuser -u otrs "${INSTALL_DIR}/bin/otrs.Console.pl" \
    'Admin::User::SetPassword' 'root@localhost' "${OTRS_ROOT_PASSWORD}" \
    &> /dev/null;
then
    print_check_result 'completed' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo
print_check_result 'Superuser password set successfully.' 1
echo
