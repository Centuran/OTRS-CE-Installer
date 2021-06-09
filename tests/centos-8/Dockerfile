FROM centos:8.3.2011 AS base

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

VOLUME [ "/sys/fs/cgroup" ]

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

#
# Stage 1: CentOS 8 with Perl installed
#

FROM base AS stage-1

RUN yum install -y perl-5.26.3

#
# Stage 2: CentOS 8 with Perl and Apache installed
#

FROM stage-1 AS stage-2

RUN yum install -y httpd-2.4.37; \
    systemctl enable httpd.service

#
# Stage 3: CentOS 8 with Perl, Apache, and MariaDB installed
#

FROM stage-2 AS stage-3

RUN yum install -y expect mariadb-server

COPY init-mariadb.sh /usr/local/sbin/

# We need to run /usr/bin/mysql_secure_installation, which requires MariaDB
# to be up (and we can't do "systemctl start" here in the Dockerfile). This ugly
# solution uses a startup script that runs the script and uses expect
# to interact with it, then removes itself.
RUN systemctl enable mariadb.service; \
    echo -e 'if [ -x /usr/local/sbin/init-mariadb.sh ]; then ' \
    '/usr/local/sbin/init-mariadb.sh; fi' >> /etc/rc.d/rc.local; \
    chmod +x /etc/rc.d/rc.local

#
# Stage 4: CentOS 8 with Perl, Apache, MariaDB, and required Perl modules
# installed
#

FROM stage-3 AS stage-4

RUN yum install -y 'perl(App::cpanminus)'; \
    yum groupinstall -y 'Development Tools'; \
    yum install -y 'perl(Date::Format)' 'perl(Net::DNS)' 'perl(XML::LibXML)'; \
    cpanm 'DateTime' 'Moo' 'Template' 'Template::Stash::XS' 'YAML::XS'
