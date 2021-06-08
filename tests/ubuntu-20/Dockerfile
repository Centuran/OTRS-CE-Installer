FROM ubuntu:20.04 AS base

#
# Stage 1: Ubuntu 20 with Perl, Apache and MariaDB installed
#

# TODO: separate installation of MariaDB
FROM base AS stage-1

RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
RUN apt-get install -y apache2

#
# Stage 2: Ubuntu 20 with Perl, Apache, MariaDB and Perl modules installed
#

FROM stage-1 AS stage-2

RUN apt-get install -y libarchive-zip-perl libdatetime-perl libmoo-perl \
    libnet-dns-perl libtemplate-perl libxml-libxml-perl libyaml-libyaml-perl