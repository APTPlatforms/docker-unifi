#!/bin/sh

mkdir -p /usr/lib/unifi/data

cat >>/usr/lib/unifi/data/system.properties <<_EOT_
unifi.db.extraargs=--smallfiles
_EOT_

java -Xmx256M -jar /usr/lib/unifi/lib/ace.jar start
