echo 'Checking for missing Perl modules...'
echo

while perl "${INSTALL_DIR}/bin/otrs.CheckModules.pl" 2> /dev/null \
    | grep -v '[Oo]ptional' | grep 'Not installed' &> /dev/null;
do
    perl "${INSTALL_DIR}/bin/otrs.CheckModules.pl" 2> /dev/null \
        | grep 'Not installed' | grep -v '[Oo]ptional' \
        | sed 's/^\s*.\s*\([^.]\+\).*$/\1/;s/^\[\S*\s*.\s*//g' \
        | while read MODULE; do
            echo -n " • Installing ${MODULE}... "
            if install_perl_module "${MODULE}"; then
                print_check_result "installed" 1
            else
                print_check_result "failed" 0
                # TODO: Explain to user, show error
                exit 1
            fi
        done
done

echo
print_check_result 'All required Perl modules are installed.' 1
echo
