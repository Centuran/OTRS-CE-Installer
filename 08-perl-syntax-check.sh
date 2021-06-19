echo "Running checks..."
echo

(
    perl -cw "${INSTALL_DIR}/bin/cgi-bin/index.pl" && \
    perl -cw "${INSTALL_DIR}/bin/cgi-bin/customer.pl" && \
    perl -cw "${INSTALL_DIR}/bin/otrs.Console.pl"
) 2>&1 | less -R | frame_output

if [ "${PIPESTATUS[0]}" != 0 ]; then
    print_check_result 'Syntax checks failed.' 0
    # TODO: Explain to user, show error
    echo
    exit 1
fi

echo
print_check_result 'Syntax checks passed.' 1
echo
