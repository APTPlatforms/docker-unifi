#!/bin/sh

mkdir -p /usr/lib/unifi/data

envsubst >>/usr/lib/unifi/data/system.properties <<_EOT_
db.mongo.local=false
db.mongo.uri=mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}
statdb.mongo.uri=mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}_stat
unifi.db.name=${MONGO_DB}
_EOT_

java -Xmx${JAVA_Xmx} -jar /usr/lib/unifi/lib/ace.jar start
