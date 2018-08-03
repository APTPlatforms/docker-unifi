#!/bin/sh

mkdir -p /usr/lib/unifi/data

cat >>/usr/lib/unifi/data/system.properties <<_EOT_
unifi.db.extraargs=--smallfiles
## device inform
unifi.http.port=8080
## controller UI / API
unifi.https.port=8443
## portal redirect port for HTTP
portal.http.port=80
## portal redirect port for HTTPs
portal.https.port=443
## local-bound port for DB server
# unifi.db.port=27117
## UDP port used for STUN
unifi.stun.port=3478
_EOT_

java -Xmx256M -jar /usr/lib/unifi/lib/ace.jar start
