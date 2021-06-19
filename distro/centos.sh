#
# Apache-related functions
#

is_apache_installed() {
    if httpd -v 2> /dev/null | grep 'Apache' &> /dev/null; then
        return 0
    else
        return 1
    fi
}

is_mod_perl_installed() {
    if yum list installed mod_perl &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_apache_config_dir() {
    echo '/etc/httpd/conf.d'
}

get_apache_group() {
    echo 'apache'
}

get_apache_version() {
    echo $(httpd -v | grep 'Apache/' | sed 's/^.*\?Apache\/\([^ ]\+\).*$/\1/')
}

install_apache() {
    yum install -y httpd 2>&1 | less -R | frame_output

    return "${PIPESTATUS[0]}"
}

install_mod_perl() {
    (
        if ! yum list installed epel-release &> /dev/null; then
            yum install -y epel-release
        fi

        yum install -y mod_perl 2>&1
    )| less -R | frame_output

    return "${PIPESTATUS[0]}"
}

restart_apache() {
    if systemctl restart httpd.service &> /dev/null; then
        return 0
    else
        return 1
    fi
}

#
# MariaDB-related functions
#

is_mariadb_installed() {
    if yum list installed mariadb-server &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_mariadb_version() {
    echo $(yum info mariadb-server | grep '^Version' | sed 's/^.*\?:\s\+//')
}

install_mariadb() {
    local ROOT_PASSWORD=$(generate_password)

    (
        yum install -y mariadb-server 2>&1
        systemctl start mariadb.service 2>&1
        systemctl enable mariadb.service 2>&1
        echo -e "\n\n${ROOT_PASSWORD}\n${ROOT_PASSWORD}\n\n\n\nn\n\n" \
            | /usr/bin/mysql_secure_installation 2>&1
    )| less -R | frame_output

    local STATUS=${PIPESTATUS[0]}

    if [ ${STATUS} = 0 ]; then
        # Set variable so that the user doesn't need to enter this password
        # for database creation step
        MARIADB_ROOT_PASSWORD="${ROOT_PASSWORD}"
        echo
        print_notice "The installer has set the MariaDB
            ${COLOR_NOTICE_BOLD}root${COLOR_NOTICE} user password to
            \"${COLOR_NOTICE_BOLD}${ROOT_PASSWORD}${COLOR_NOTICE}\" (without the
            quotes). Please keep this password safe or change it."
        # TODO: Tell the user how to change the password or what docs to read
        echo

        print_centered "Press $(style_key Enter) to proceed." 80
        echo

        expect_enter
    fi

    return "${STATUS}"
}

#
# Other functions
#

install_perl_module() {
    local MODULE=$1

    if yum install -y "perl(${MODULE})" &> /dev/null; then
        return 0
    else
        if ! cpanm --version &> /dev/null < /dev/null; then
            if ! yum install -y 'perl(App::cpanminus)' &> /dev/null; then
                # TODO: Handle error
                return 1
            fi
            
            yum groupinstall -y "Development Tools" &> /dev/null

            if [ $? -ne 0 ]; then
                yum groups mark install "Development Tools" &> /dev/null
                yum groups mark convert "Development Tools" &> /dev/null
                yum groupinstall -y "Development Tools" &> /dev/null
            fi
        fi

        if cpanm "${MODULE}" &> /dev/null < /dev/null; then
            return 0
        else
            return 1
        fi
    fi
}

install_bzip2() {
    yum install -y bzip2 2>&1 | less -R | frame_output
    
    return "${PIPESTATUS[0]}"
}

if [ -z "${LC_CTYPE}" ]; then
    # Silence the "Setting locale failed" warnings
    export LC_CTYPE='C.UTF-8'
    export LC_ALL='C.UTF-8'
fi
