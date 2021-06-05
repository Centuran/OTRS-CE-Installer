frame_output() {
    local TTY="/dev/"$(ps hotty $$)
    # Set frame width to the width of the terminal minus 4 columns
    local FRAME_WIDTH=$(($(stty -F "$TTY" size | sed 's/^.* //') - 4))
    local FRAME_HEIGHT=${1:-5}                # 5 lines by default
    local FRAME_STYLE=${2:-rounded}

    if [ "${FRAME_STYLE}" = 'rounded' ]; then
        local TL='╭'    # Top left
        local TR='╮'    # Top right
        local BL='╰'    # Bottom left
        local BR='╯'    # Bottom right
        local LH='─'    # Horizontal
        local LV='│'    # Vertical
    else 
        local TL='┏'    # Top left
        local TR='┓'    # Top right
        local BL='┗'    # Bottom left
        local BR='┛'    # Bottom right
        local LH='━'    # Horizontal
        local LV='┃'    # Vertical
    fi

    echo -n -e '\033[?25l'  # Hide cursor

    echo -n -e "${COLOR_LIGHT_BLACK_BOLD}"
    
    # Draw top border
    echo -n " ${TL}"
    printf "${LH}%.0s" $(seq 1 ${FRAME_WIDTH})
    echo "${TR}"
    
    # Draw left and right borders
    for ROW in $(seq 1 ${FRAME_HEIGHT}); do
        echo -n " ${LV}"
        printf ' %.0s' $(seq 1 ${FRAME_WIDTH})
        echo "${LV}"
    done

    # Draw bottom border
    echo -n " ${BL}"
    printf "${LH}%.0s" $(seq 1 ${FRAME_WIDTH})
    echo "${BR}"
    
    echo -n -e "${COLOR_NONE}"
    
    echo -e "\\033[${FRAME_HEIGHT}A"    # Move up $FRAME_HEIGHT lines
    echo -e '\033[3A'                   # Move up 3 more (to account for border)

    local BUF=()

    while read LINE; do
        BUF+=("${LINE}")
        local BUF_LENGTH=${#BUF[@]}

        if [ "$BUF_LENGTH" -gt "$FRAME_HEIGHT" ]; then
            BUF=("${BUF[@]:1}")
            BUF_LENGTH=$((${BUF_LENGTH} - 1))
        fi

        for BUF_LINE in "${BUF[@]}"; do
            echo -n -e "\r\\033[2C"     # Carriage return, 2 columns forward
            printf ' %.0s' $(seq 1 ${FRAME_WIDTH})
            echo -n -e "\r\\033[2C"     # Carriage return, 2 columns forward
            printf "%.${FRAME_WIDTH}s\n" "${BUF_LINE}"
        done

        local SHIFT=$((${BUF_LENGTH} + 1))
        echo -e "\\033[${SHIFT}A"
    done

    # Finally move down $FRAME_HEIGHT lines to not end up in frame top line
    echo -e "\\033[${FRAME_HEIGHT}B"

    echo -n -e '\033[34h\033[?25h'  # Show cursor
}
