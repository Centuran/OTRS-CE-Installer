FROM ubuntu:20.04 AS base

RUN apt-get update
RUN apt-get install -y less
RUN ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
RUN apt-get install -y systemd

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*

#
# Stage 1: Ubuntu 20 with Perl and Apache installed
#

FROM base AS stage-1

RUN apt-get install -y apache2

#
# Stage 2: Ubuntu 20 with Perl, Apache and MariaDB installed
#

FROM stage-1 AS stage-2

RUN apt-get install -y mariadb-server

COPY init-mariadb.sh /usr/local/sbin/

# We need to run /usr/bin/mysql_secure_installation, which requires MariaDB
# to be up (and we can't do "systemctl start" here in the Dockerfile). This ugly
# solution uses a startup script that runs the script and uses expect
# to interact with it, then removes itself.
RUN systemctl enable mariadb.service; \
    echo -e 'if [ -x /usr/local/sbin/init-mariadb.sh ]; then ' \
    '/usr/local/sbin/init-mariadb.sh; fi' >> /etc/init.d/mariadb_init; \
    chmod +x /etc/init.d/mariadb_init

#
# Stage 3: Ubuntu 20 with Perl, Apache, MariaDB and Perl modules installed
#

FROM stage-2 AS stage-3

RUN apt-get install -y libarchive-zip-perl libdatetime-perl libmoo-perl \
    libnet-dns-perl libtemplate-perl libxml-libxml-perl libyaml-libyaml-perl