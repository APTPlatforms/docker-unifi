FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_OPTS="-o APT::Install-Recommends=0 -o APT::Install-Suggests=0"

# man1 directory doesn't exist. We create it to satisfy openjdk-8-jre-headless install
RUN mkdir -p /usr/share/man/man1

# Install apt-utils
RUN apt-get update \
 && apt-get -y $APT_OPTS install apt-utils \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install support packages
RUN apt-get update \
 && apt-get -y $APT_OPTS install curl gdebi-core procps openjdk-8-jre-headless mongodb-server \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Retrieve UniFi signing keys and install the specific controller package
ARG UNIFI_CONTROLLER_VERSION=5.8.30
RUN curl -s -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg \
 && echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list \
 && curl -s -o /tmp/unifi.deb https://dl.ubnt.com/unifi/$UNIFI_CONTROLLER_VERSION/unifi_sysvinit_all.deb \
 && apt-get update \
 && gdebi -n $APT_OPTS /tmp/unifi.deb \
 && rm -rf /tmp/unifi.deb /var/lib/apt/lists/* /var/cache/apt/*

# Cleanup
RUN apt-get update \
 && apt-get -y dist-upgrade \
 && apt-get -y --purge autoremove \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Link logs to stdout for Docker
RUN mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 /tini
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
RUN chmod 0755 /tini /docker-entrypoint.sh

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
