#!/bin/bash

set -e

SCRIPT=$(realpath -s $0)
SCRIPT_DIR=$(dirname ${SCRIPT})

# FIXME: Read from RELEASE?
VERSION="6.0.32"

if ! test -t 1; then
    # Not a terminal
    # TODO: Display error
    exit 1
fi

# Load utility functions
source "${SCRIPT_DIR}/utils/frame.sh"
source "${SCRIPT_DIR}/utils/input.sh"
source "${SCRIPT_DIR}/utils/misc.sh"
source "${SCRIPT_DIR}/utils/output.sh"
source "${SCRIPT_DIR}/utils/styles.sh"

TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "${TMP_DIR}"
}

trap cleanup EXIT

restore_terminal() {
    # Make cursor visible, in case we have made it disappear
    # (NOTE: we could do this using "tput cnorm", but tput might not be present)
    echo -e '\033[34h\033[?25h'
}

trap restore_terminal EXIT

# TODO: Check if running as root

# TODO: Check if colors supported
# TODO: Check if columns >= 80
# TODO: Check if lines >= 25

cat "${SCRIPT_DIR}/start.utf8ans"

echo
print_centered '•   •   •' 80
echo
echo

print_centered "This program will install
    ${COLOR_LIGHT_BLUE_BOLD}((OTRS)) Community Edition${COLOR_NONE}
    version ${COLOR_LIGHT_WHITE_BOLD}${VERSION}${COLOR_NONE}." 80
echo

print_centered "Press $(style_key Enter) to start installation, or
    $(style_key Esc) to exit." 80
echo

expect_enter_exit_on_esc

INSTALL_DIR='/opt/otrs'
SYSTEM_USER='otrs'

echo -e "\nStarting installation...\n"

source "${SCRIPT_DIR}/distro/all.sh"

#
# Step 1: Check prerequisites
#

print_step 1 "Check prerequisites"

source "${SCRIPT_DIR}/01-prerequisites.sh"

# Load system-specific functions
if [[ "${SYSTEM}" == 'centos/'* ]]; then
    source "${SCRIPT_DIR}/distro/centos.sh"
elif [[ "${SYSTEM}" == 'ubuntu/20'* ]]; then
    source "${SCRIPT_DIR}/distro/ubuntu20.sh"
elif [[ "${SYSTEM}" == 'ubuntu/21'* ]]; then
    source "${SCRIPT_DIR}/distro/ubuntu21.sh"
fi

echo

#
# Step 2: Check required software
#

print_step 2 'Check required software'

source "${SCRIPT_DIR}/02-server-software.sh"

echo

#
# Step 3: Extract files
#

print_step 3 'Extract files'

source "${SCRIPT_DIR}/03-files.sh"

echo

#
# Step 4: Install required Perl modules
#

print_step 4 'Install required Perl modules'

source "${SCRIPT_DIR}/04-perl-modules.sh"

echo

#
# Step 5: Create database
#

print_step 5 'Create database'

source "${SCRIPT_DIR}/05-database.sh"

echo

#
# Step 6: Create system user
#

print_step 6 'Create system user'

source "${SCRIPT_DIR}/06-user.sh"

echo

#
# Step 7: Initialize configuration file
#

print_step 7 'Initialize configuration file'

source "${SCRIPT_DIR}/07-config-file.sh"

echo

#
# Step 8: Perform Perl syntax check
#

print_step 8 'Perform Perl syntax check'

source "${SCRIPT_DIR}/08-perl-syntax-check.sh"

echo

#
# Step 9: Configure HTTP server
#

print_step 9 'Configure HTTP server'

source "${SCRIPT_DIR}/09-http-configuration.sh"

echo

#
# Step 10: Set file permissions
#

print_step 10 'Set file permissions'

source "${SCRIPT_DIR}/10-file-permissions.sh"

echo

#
# Step 11: Start daemon process
#

print_step 11 'Start daemon process'

source "${SCRIPT_DIR}/11-daemon.sh"

echo

#
# Step 12: Set up cron jobs
#

print_step 12 'Set up cron jobs'

source "${SCRIPT_DIR}/12-cron-jobs.sh"

echo

#
# Step 13: Set superuser password
#

print_step 13 'Set superuser password'

source "${SCRIPT_DIR}/13-superuser-password.sh"

echo
print_centered '•   •   •' 80
echo
echo

print_centered "${COLOR_SUCCESS_ACCENTED}Installation completed!${COLOR_NONE}" \
    80
echo
echo

OTRS_CE_URL="http://$(hostname -i)/otrs/index.pl"

print_centered "You can now log in to the installed system at:" 80
echo
print_centered "${COLOR_LINK}${OTRS_CE_URL}${COLOR_NONE}" 80
echo
echo

print_centered "Press any key to exit." 80
echo

exit_on_any_key
