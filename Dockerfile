FROM alpine:3.7
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

# NOTE: alpine 3.7 is the last version with MongoDB 3.4. 3.8 uses MongoDB 3.6
#       which does not work with UniFi SDN

RUN : \
 && echo "### Install support packages. Upgrade base image." \
 && apk update \
 && apk upgrade --purge \
 && apk add openjdk8-jre-base mongodb tini \
 && echo "### Cleanup apk cache" \
 && rm -rf /var/cache/apk/*

ARG UNIFI_SDN_VERSION=5.9.29

ADD http://www.ubnt.com/downloads/unifi/$UNIFI_SDN_VERSION/UniFi.unix.zip /tmp/UniFi.unix.zip

RUN : \
 && echo "### Unpack/Install UniFi $UNIFI_SDN_VERSION" \
 && rm -rf /usr/lib/unifi \
 && mkdir -p /usr/lib \
 && unzip -q /tmp/UniFi.unix.zip -d /usr/lib \
 && ln -s ./UniFi /usr/lib/unifi \
 && : \
 && echo "### Setup mongodb links" \
 && rm -rf /usr/lib/unifi/bin/mongod \
 && ln -s `which mongod` /usr/lib/unifi/bin/mongod \
 && : \
 && echo "### Link logs to stdout for Docker" \
 && mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log \
 && : \
 && echo "### Remove source archive" \
 && rm -rf /tmp/UniFi.unix.zip

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/bin/sh", "/docker-entrypoint.sh"]

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
