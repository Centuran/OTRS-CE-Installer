expect_enter_exit_on_esc() {
    local STATUS=${1:-0}
    local KEY=

    while [ "$KEY" != $'\x0a' ]; do
        read -s -N1 KEY

        case $KEY in
            $'\e') exit ${STATUS};;
        esac
    done
}

exit_on_any_key() {
    local STATUS=${1:-0}
    local KEY

    read -s -N1 KEY
    exit ${STATUS}
}

expect_enter() {
    local KEY

    while [ "${KEY}" != $'\x0a' ]; do
        read -s -N1 KEY
    done
}

# Based on https://stackoverflow.com/a/24600839/922599
read_password() {
    stty -echo

    local PASSWORD
    local CHAR
    local CHAR_COUNT=0
    local PROMPT

    while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
    do
        # Enter - accept password
        if [[ $CHAR == $'\0' ]] ; then
            break
        fi
        # Backspace
        if [[ $CHAR == $'\177' ]] ; then
            if [ $CHAR_COUNT -gt 0 ] ; then
                CHAR_COUNT=$((CHAR_COUNT-1))
                PROMPT=$'\b \b'
                PASSWORD="${PASSWORD%?}"
            else
                PROMPT=''
            fi
        else
            CHAR_COUNT=$((CHAR_COUNT+1))
            PROMPT='•'
            PASSWORD+="$CHAR"
        fi
    done

    stty echo

    echo -n ${PASSWORD}
}
