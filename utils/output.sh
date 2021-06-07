print_step() {
    number=$1
    title=$2

    echo -e "${COLOR_LIGHT_BLUE_BG}${COLOR_WHITE_BOLD} ${number}" \
        "${COLOR_NONE} ${COLOR_LIGHT_BLUE_BOLD}${title}${COLOR_NONE}"
    echo
}

print_check_result() {
    text=$1
    success=$2

    if [ "$success" -eq 1 ]; then
        echo -e "${COLOR_SUCCESS_ACCENTED}${text}${COLOR_NONE}" \
            "${RESULT_SUCCESS}"
    else
        echo -e "${COLOR_FAILURE_ACCENTED}${text}${COLOR_NONE}" \
            "${RESULT_FAILURE}"
    fi
}

print_notice() {
    local TEXT=$1
    local NO_COLOR=$2

    echo -ne "${COLOR_NOTICE_BG}${COLOR_INVERTED_BOLD} ! ${COLOR_NONE} "

    TEXT=$(echo "${TEXT}" | sed 's/^\s*//')

    if [ -z "${NO_COLOR}" ]; then
        echo -ne "${COLOR_NOTICE}"
    fi

    echo -e "${TEXT}" | tr '\n' ' ' | fold -w 76 -s - \
        | sed '2,$s/^/    /' | cat

    if [ -z "${NO_COLOR}" ]; then
        echo -ne "${COLOR_NONE}"
    fi

    echo
}

print_centered() {
    local TEXT=$1
    local WIDTH=$2

    TEXT=$(echo -n "${TEXT}" | sed 's/^\s*//' | tr '\n' ' ')
    local TEXT_PLAIN=$(echo "${TEXT}" | sed 's/\\033[^m]*m//g')

    if [ -z "${WIDTH}" ]; then
        local TTY="/dev/"$(ps hotty $$)
        WIDTH=$(stty -F "$TTY" size | sed 's/^.* //')
    fi

    if [ -z "${LC_ALL}" ]; then
        # Set locale so that Unicode string length is correct
        LC_ALL=C.UTF-8
    fi

    let PAD="($WIDTH - ${#TEXT_PLAIN}) / 2"
    printf "%${PAD}s%b%s" " " "${TEXT}"
}
