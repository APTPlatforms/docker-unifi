FROM debian:9-slim
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_OPTS="-o APT::Install-Recommends=0 -o APT::Install-Suggests=0"
ARG UNIFI_CONTROLLER_VERSION=6.0.28
ARG TINI_VERSION=v0.19.0

RUN set -ex \
 && echo "### Install apt-utils" \
 && apt-get update \
 && apt-get -y $APT_OPTS install apt-utils \
 && apt-get -y $APT_OPTS dist-upgrade \
 && apt-get -y $APT_OPTS install curl gnupg2 ca-certificates apt-transport-https \
# && :
#RUN set -ex \
 && echo "### Install mongoDB packages." \
 && curl -sL https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add - \
 && echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/3.6 main" > /etc/apt/sources.list.d/mongodb-org-3.6.list \
 && apt-get update \
 && apt-get -y $APT_OPTS install mongodb-org-server mongodb-org-tools \
# && :
#RUN set -ex \
 && echo "### Install UniFi Controller package" \
 && mkdir -p /usr/share/man/man1 \
 && curl -sL -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg \
 && echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list \
 && apt-get update \
 && apt-get -y $APT_OPTS install bsd-mailx openjdk-8-jre-headless procps unifi \
# && :
#RUN set -ex \
 && apt-get -y $APT_OPTS --purge autoremove \
 && apt-get clean \
 && find /var/lib/apt/lists/ /var/cache/apt/ -type f -exec rm -rf {} + \
# && :
#RUN set -ex \
 && echo "### Install tini" \
 && curl -sL -o /sbin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 \
 && chmod 00755 /sbin/tini \
# && :
#RUN set -ex \
 && echo "### Link logs to stdout for Docker" \
 && mkdir -p /usr/lib/unifi/logs \
 && rm -f /usr/lib/unifi/logs/server.log \
 && ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log \
 && :

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["tini", "--"]
CMD ["sh", "/docker-entrypoint.sh"]

WORKDIR /usr/lib/unifi
VOLUME /usr/lib/unifi/data
EXPOSE 8080/tcp 8443/tcp 443/tcp 80/tcp 3478/udp

# vim:filetype=dockerfile
