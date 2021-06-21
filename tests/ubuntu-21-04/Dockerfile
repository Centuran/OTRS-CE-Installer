FROM ubuntu:21.04 AS base

ENV container docker

RUN ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime; \
    apt-get update; \
    apt-get install -y systemd systemd-sysv; \
    apt-get install -y less

# Commands below are based on jrei/systemd-ubuntu

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

#
# Stage 1: Ubuntu 21.04 with Apache installed
#

FROM base AS stage-1

RUN apt-get install -y apache2; \
    systemctl enable apache2

#
# Stage 2: Ubuntu 21.04 with Apache and MariaDB installed
#

FROM stage-1 AS stage-2

RUN apt-get install -y mariadb-server

COPY init-mariadb.sh /usr/local/sbin/

RUN systemctl enable mariadb.service; \
    echo -e 'if [ -x /usr/local/sbin/init-mariadb.sh ]; then ' \
    '/usr/local/sbin/init-mariadb.sh; fi'

#
# Stage 3: Ubuntu 21.04 with Apache, MariaDB and Perl modules installed
#

FROM stage-2 AS stage-3

RUN apt-get install -y libarchive-zip-perl libdatetime-perl libmoo-perl \
    libnet-dns-perl libtemplate-perl libxml-libxml-perl libyaml-libyaml-perl
