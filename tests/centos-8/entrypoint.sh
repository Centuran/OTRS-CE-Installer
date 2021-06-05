#!/bin/bash

cat > /lib/systemd/system/command.service <<END
[Unit]
Description=Command

[Service]
Type=idle
StandardInput=tty
ExecStart="$@"
ExecStopPost=/usr/bin/systemctl poweroff

[Install]
WantedBy=multi-user.target
END

systemctl enable command

exec /usr/sbin/init

# TODO: Silence systemd logging output to console
