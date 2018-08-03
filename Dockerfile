# vim:filetype=dockerfile
FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG UNIFI_CONTROLLER_VERSION=5.8.24

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-build.sh /docker-build.sh

RUN /bin/sh /docker-build.sh && rm -f /docker-build.sh

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
