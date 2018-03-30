# vim:filetype=dockerfile
FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 0755 /docker-entrypoint.sh \
 && apt-get update \
 && apt-get -y install apt-utils curl \
 && apt-get -y dist-upgrade \
 && curl -s -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg \
 && echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list \
 && apt-get update \
 && mkdir -p /usr/share/man/man1 \
 && apt-get -y install \
                 openjdk-8-jre-headless \
                 mongodb-server \
                 unifi \
                 procps \
 && apt-get -y --purge autoremove \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/* ~/.cache \
 && mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8443/tcp 8843/tcp 8880/tcp 8080/tcp 3478/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
