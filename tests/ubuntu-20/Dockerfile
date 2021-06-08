FROM ubuntu:20.04 AS base


# TODO: separate installation of MariaDB
FROM base AS stage-1

RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
RUN apt-get install -y apache2