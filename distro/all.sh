# Functions in this file need to be available for the prerequisites check
# (step 1), so before system-specific functions (e.g. "distro/centos.sh")
# are included. It is assumed, though, that the $SYSTEM variable is already
# set.

install_perl() {
    local STATUS=1

    if [[ "${SYSTEM}" == 'centos/'* ]]; then
        yum install -y perl 2>&1 | less -R | frame_output

        STATUS=${PIPESTATUS[0]}
    fi

    return "${STATUS}"
}
