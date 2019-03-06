FROM alpine:3.7
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

# NOTE: alpine:3.7 is the last version with MongoDB-3.4.
#       alpine:3.8+ uses MongoDB-3.6 which does not work with UniFi SDN.

RUN : \
 && echo "###    Alpine Linux :: UPGRADE" \
 && apk upgrade --no-cache --purge \
 && echo "###    Alpine Linux :: UniFi SDN support" \
 && apk add --no-cache curl libc6-compat openjdk8-jre-base mongodb tini \
 && echo "###    Alpine Linux :: CLEANUP" \
 && rm -rf /var/cache/apk/*

ARG UNIFI_SDN_VERSION=5.10.19

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN : \
 && echo "### UniFi SDN $UNIFI_SDN_VERSION :: INSTALL" \
 && rm -rf /usr/lib/unifi \
 && mkdir -p /usr/lib \
 && curl -sL -o /tmp/UniFi.unix.zip http://www.ubnt.com/downloads/unifi/$UNIFI_SDN_VERSION/UniFi.unix.zip \
 && unzip -q /tmp/UniFi.unix.zip -d /usr/lib \
 && ln -s ./UniFi /usr/lib/unifi \
 && rm -rf /tmp/UniFi.unix.zip \
 && : \
 && echo "### UniFi SDN $UNIFI_SDN_VERSION :: SETUP(MongoDB)" \
 && rm -rf /usr/lib/unifi/bin/mongod \
 && ln -s `which mongod` /usr/lib/unifi/bin/mongod \
 && : \
 && echo "### UniFi SDN $UNIFI_SDN_VERSION :: SETUP(LOGS)" \
 && mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log \
 && : \
 && chmod 00555 /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-v", "--"]
CMD ["/docker-entrypoint.sh"]

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
