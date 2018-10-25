FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_OPTS="-o APT::Install-Recommends=0 -o APT::Install-Suggests=0"
ARG UNIFI_CONTROLLER_VERSION=5.9.29
ARG TINI_VERSION=v0.18.0

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN echo "### man1 directory doesn't exist. We create it to satisfy openjdk-8-jre-headless install" \
 && mkdir -p /usr/share/man/man1 \
 && : \
 && echo "### Install apt-utils" \
 && apt-get update \
 && apt-get -y $APT_OPTS install apt-utils \
 && : \
 && echo "### Install support packages. Upgrade base image." \
 && apt-get -y $APT_OPTS install curl gdebi-core procps openjdk-8-jre-headless mongodb-server \
 && apt-get -y dist-upgrade \
 && apt-get -y --purge autoremove \
 && : \
 && echo "### Retrieve UniFi signing keys and install the specific controller package" \
 && curl -sL -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg \
 && echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list \
 && curl -sL -o /tmp/unifi.deb https://dl.ubnt.com/unifi/$UNIFI_CONTROLLER_VERSION/unifi_sysvinit_all.deb \
 && apt-get update \
 && gdebi -n $APT_OPTS /tmp/unifi.deb \
 && : \
 && echo "### Cleanup cache" \
 && rm -rf /tmp/unifi.deb /var/lib/apt/lists/* /var/cache/apt/* \
 && : \
 && echo "### Link logs to stdout for Docker" \
 && mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log \
 && : \
 && echo "### Install tini" \
 && curl -sL -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 \
 && : \
 && echo "### Make files executable" \
 && chmod 0755 /tini /docker-entrypoint.sh

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
