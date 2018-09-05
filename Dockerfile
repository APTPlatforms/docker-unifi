FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive

# man1 directory doesn't exist. We create it to satisfy openjdk-8-jre-headless install
RUN mkdir -p /usr/share/man/man1

# Update platform
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y dist-upgrade

# Install support packages
RUN apt-get -y install curl gdebi-core procps openjdk-8-jre-headless mongodb-server

# Retrieve UniFi signing keys
RUN curl -s -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
RUN echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list
RUN apt-get update

# Install the specific controller package
ARG UNIFI_CONTROLLER_VERSION=5.8.24
RUN curl -s -o /tmp/unifi.deb https://dl.ubnt.com/unifi/$UNIFI_CONTROLLER_VERSION/unifi_sysvinit_all.deb
RUN gdebi -n /tmp/unifi.deb

# Cleanup
RUN apt-get -y --purge autoremove
RUN rm -rf /tmp/unifi.deb /var/lib/apt/lists/* /var/cache/apt/* ~/.cache

# Link logs to stdout for Docker
RUN mkdir -p /usr/lib/unifi/logs
RUN rm -f /usr/lib/unifi/logs/server.log
RUN ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
