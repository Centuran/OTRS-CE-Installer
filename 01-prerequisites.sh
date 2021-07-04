# TODO: Check amount of RAM

check() {
    local STATUS_OK=0
    local STATUS_FAILURE=101

    STATUS=${STATUS_OK}

    # Check if the OS is supported

    declare -A SUPPORTED_SYSTEMS
    SUPPORTED_SYSTEMS=(
        [centos/8]=1
        [ubuntu/20.04]=1
        [ubuntu/21.04]=1
    )

    echo -n ' • Checking OS version:          '

    # TODO: Checking for os-release should probably also be moved to utils/system.sh
    if [ -f /etc/os-release ]; then
        SYSTEM_NAME="$(get_system_name)"
        SYSTEM="$(get_system)"
        export SYSTEM

        if [ ${SUPPORTED_SYSTEMS[${SYSTEM}]+_} ]; then
            print_check_result "${SYSTEM_NAME}" 1
        else
            SYSTEM_UNSUPPORTED=1
            STATUS=${STATUS_FAILURE}
            print_check_result "${SYSTEM_NAME}" 0
        fi
    else
        SYSTEM_OS_RELEASE_NOT_FOUND=1
        STATUS=${STATUS_FAILURE}
        print_check_result "/etc/os-release not found" 0
    fi

    # Check if SELinux is disabled or not present

    echo -n ' • Checking SELinux status:      '

    if [ -e /sys/fs/selinux ]; then
        local GETENFORCE=$(getenforce)

        if [ "${GETENFORCE}" == 'Enforcing' ]; then
            print_check_result "SELinux is set to \"Enforcing\"" 0
        else
            print_check_result "SELinux is set to \"${GETENFORCE}\"" 1
        fi
    else
        print_check_result "SELinux is not present" 1
    fi

    # Check if Perl is installed and is the required version

    PERL_NOT_INSTALLED=
    PERL_TOO_OLD=

    echo -n ' • Checking Perl version:        '

    if perl -e1 &> /dev/null; then
        PERL_VERSION=$(perl -e 'print substr($^V, 1)' 2> /dev/null)
        local PERL_VERSION_INT=$(perl -e 'print $] * 1_000_000' 2> /dev/null)

        if [ "${PERL_VERSION_INT}" -gt "5016000" ]; then
            print_check_result "${PERL_VERSION}" 1
        else
            PERL_TOO_OLD=1
            print_check_result "${PERL_VERSION}" 0
        fi
    else
        PERL_NOT_INSTALLED=1
        STATUS=${STATUS_FAILURE}
        print_check_result "Perl not found" 0
    fi

    # Check if /opt/otrs is non-existent or empty

    echo -n ' • Checking installation folder: '

    INSTALL_DIR='/opt/otrs'

    if [ -e "${INSTALL_DIR}" ]; then
        if [ ! -w "${INSTALL_DIR}" ]; then
            print_check_result "no write access to ${INSTALL_DIR}" 0
        elif [ -z "$(ls -A ${INSTALL_DIR})" ]; then
            print_check_result "${INSTALL_DIR} is empty" 1
        else
            print_check_result "${INSTALL_DIR} is not empty" 0
        fi
    else
        print_check_result "${INSTALL_DIR} does not exist" 1
    fi

    return ${STATUS}
}

act() {
    if [ "${SYSTEM_UNSUPPORTED}" = 1 ]; then
        echo -en "${COLOR_ERROR}"
        echo -e "This system (${SYSTEM_NAME}) is not supported by the installer."
        echo -en "${COLOR_NONE}"
        echo
        echo "Press any key to exit."

        exit_on_any_key
    fi

    if [ "${PERL_NOT_INSTALLED}" = 1 ]; then
        print_notice "It appears Perl is not installed on this system.
            The installer can attempt to fix this and install Perl using
            standard system software repositories."
        echo

        print_centered "Press $(style_key Enter) to install Perl, or
            $(style_key Esc) to exit." 80
        echo

        expect_enter_exit_on_esc

        echo
        echo "Installing Perl..."
        echo

        install_perl
        # TODO: Check result
    fi
}

while ! check; do
    echo

    act

    echo
    echo "Repeating checks..."
    echo
done

echo
print_check_result 'Prerequisites check successful.' 1
echo
