# Read the specified value from the /etc/os-release file
read_os_release() {
    local NAME=$1
    printf "$(cat /etc/os-release | grep "^${NAME}=" | sed 's/^.*=//;s/"//g')"
}

get_system() {
    local SYSTEM_TYPE=$(read_os_release ID)
    local SYSTEM_VERSION=$(read_os_release VERSION_ID)
    printf "${SYSTEM_TYPE}/${SYSTEM_VERSION}"
}

get_system_name() {
    printf "$(read_os_release PRETTY_NAME)"
}
