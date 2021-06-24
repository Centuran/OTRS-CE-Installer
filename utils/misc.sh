generate_password() {
    local LENGTH=${1:-12}

    (cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c "${LENGTH}") 2> /dev/null
}

get_ip_address() {
    local PRIVATE_ADDRESS
    local NON_PRIVATE_ADDRESS

    local PRIVATE_ADDRESS_RE=$(printf '
        \(^127\.\)\|
        \(^10\.\)\|
        \(^172\.1[6-9]\.\)\|\(^172\.2[0-9]\.\)\|\(^172\.3[0-1]\.\)\|
        \(^192\.168\.\)
    ' | tr -d '\n ')

    for ADDRESS in $(hostname -I); do
        # Ignore IPv6 addresses
        if printf "${ADDRESS}" | grep ':' &> /dev/null; then
            continue
        fi

        if printf "${ADDRESS}" | grep "${PRIVATE_ADDRESS_RE}" &> /dev/null; then
            if [ -z "${PRIVATE_ADDRESS}" ]; then
                PRIVATE_ADDRESS="${ADDRESS}"
            fi
        else
            if [ -z "${NON_PRIVATE_ADDRESS}" ]; then
                NON_PRIVATE_ADDRESS="${ADDRESS}"
            fi
        fi
    done

    if [ ! -z "${NON_PRIVATE_ADDRESS}" ]; then
        printf "${NON_PRIVATE_ADDRESS}"
    elif [ ! -z "${PRIVATE_ADDRESS}" ]; then
        printf "${PRIVATE_ADDRESS}"
    else
        printf '127.0.0.1'
    fi
}
