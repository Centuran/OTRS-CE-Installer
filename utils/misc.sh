generate_password() {
    local LENGTH=${1:-12}

    (cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c "${LENGTH}") 2> /dev/null
}
