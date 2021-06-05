#
# Apache-related functions
#

is_apache_installed() {
    if apache2 -v 2> /dev/null | grep 'Apache' &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_apache_group() {
    echo 'www-data'
}

get_apache_version() {
    echo $(apache2 -v | grep 'Apache/' | sed 's/^.*\?Apache\/\([^ ]\+\).*$/\1/')
}

install_apache() {
    # TODO
}
