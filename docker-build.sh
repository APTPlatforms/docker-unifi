#!/bin/sh

set -ex

# man1 directory doesn't exist. We create it to satisfy openjdk-8-jre-headless install
mkdir -p /usr/share/man/man1

# Update platform
apt-get update
apt-get -y install apt-utils
apt-get -y dist-upgrade

# Install support packages
apt-get -y install curl gdebi-core procps openjdk-8-jre-headless mongodb-server

# Retrieve UniFi signing keys
curl -s -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/ubnt-unifi.list
apt-get update

# Install the specific controller package
curl -s -o /tmp/unifi.deb https://dl.ubnt.com/unifi/$UNIFI_CONTROLLER_VERSION/unifi_sysvinit_all.deb
gdebi -n /tmp/unifi.deb

# Cleanup
apt-get -y --purge autoremove
rm -rf /tmp/unifi.deb /var/lib/apt/lists/* /var/cache/apt/* ~/.cache

# Link logs to stdout for Docker
mkdir -p /usr/lib/unifi/logs
rm -f /usr/lib/unifi/logs/server.log
ln -s /proc/self/fd/1 /usr/lib/unifi/logs/server.log

# Change permissions on entrypoint
chmod 0755 /docker-entrypoint.sh
