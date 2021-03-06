NUM_COLORS=0
if [ "${COLORTERM}" = 'truecolor' ]; then
    NUM_COLORS=256
fi

COLOR_NONE='\033[0m'
COLOR_BLACK='\033[0;30m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_LIGHT_BLACK='\033[0;90m'
COLOR_LIGHT_RED='\033[0;91m'
COLOR_LIGHT_GREEN='\033[0;92m'
COLOR_LIGHT_YELLOW='\033[0;93m'
COLOR_LIGHT_BLUE='\033[0;94m'
COLOR_BLACK_BOLD='\033[1;30m'
COLOR_RED_BOLD='\033[1;31m'
COLOR_GREEN_BOLD='\033[1;32m'
COLOR_YELLOW_BOLD='\033[1;33m'
COLOR_WHITE_BOLD='\033[1;37m'
COLOR_LIGHT_BLACK_BOLD='\033[1;90m'
COLOR_LIGHT_RED_BOLD='\033[1;91m'
COLOR_LIGHT_GREEN_BOLD='\033[1;92m'
COLOR_LIGHT_YELLOW_BOLD='\033[1;93m'
COLOR_LIGHT_BLUE_BOLD='\033[1;94m'
COLOR_LIGHT_WHITE_BOLD='\033[1;97m'
COLOR_RED_BG='\033[41m'
COLOR_GREEN_BG='\033[42m'
COLOR_YELLOW_BG='\033[43m'
COLOR_WHITE_BG='\033[47m'
COLOR_LIGHT_YELLOW_BG='\033[0;103m'
COLOR_LIGHT_BLUE_BG='\033[0;104m'

COLOR_SUCCESS="${COLOR_LIGHT_GREEN}"
COLOR_SUCCESS_ACCENTED="${COLOR_LIGHT_GREEN_BOLD}"
COLOR_WARNING="${COLOR_LIGHT_YELLOW}"
COLOR_WARNING_BOLD="${COLOR_LIGHT_YELLOW_BOLD}"
COLOR_WARNING_BG="${COLOR_LIGHT_YELLOW_BG}"
COLOR_NOTICE="${COLOR_WARNING}"
COLOR_NOTICE_BOLD="${COLOR_WARNING_BOLD}"
COLOR_NOTICE_BG="${COLOR_WARNING_BG}"
COLOR_ERROR="${COLOR_LIGHT_RED}"
COLOR_ERROR_ACCENTED="${COLOR_LIGHT_RED_BOLD}"
COLOR_FAILURE="${COLOR_ERROR}"
COLOR_FAILURE_ACCENTED="${COLOR_ERROR_ACCENTED}"

COLOR_LINK="${COLOR_LIGHT_BLUE}"

COLOR_INVERTED="${COLOR_BLACK}"
COLOR_INVERTED_BOLD="${COLOR_BLACK_BOLD}"

RESULT_SUCCESS="${COLOR_GREEN_BG}${COLOR_WHITE_BOLD} OK ${COLOR_NONE}"
RESULT_FAILURE="${COLOR_RED_BG}${COLOR_WHITE_BOLD} ERROR ${COLOR_NONE}"

style_key() {
    TEXT=$1

    echo "${COLOR_LIGHT_BLACK_BOLD}${COLOR_WHITE_BG} ${TEXT} ${COLOR_NONE}"
}
