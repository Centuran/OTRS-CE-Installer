echo -n 'Creating cron files... '

COPY_SUCCESS=1

for FILE in "${INSTALL_DIR}/var/cron/"*.dist; do
    if ! cp "${FILE}" "${INSTALL_DIR}/var/cron/"$(basename "${FILE}" .dist);
    then
        COPY_SUCCESS=0
    fi
done

if [ "${COPY_SUCCESS}" = 1 ]; then
    print_check_result 'created' 1
else
    print_check_result 'failed' 0
    # TODO: Explain to user, retry?
    exit 1
fi

echo
print_check_result 'Cron jobs set up successfully.' 1
echo
