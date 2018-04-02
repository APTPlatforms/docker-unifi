#!/bin/sh

mkdir -p /usr/lib/unifi/data

grep '^uuid=' /usr/lib/unifi/data/system.properties >/system.properties

if [ "$MONGO_REMOTE" = "true" ]
then
    envsubst >>/system.properties <<_EOT_
db.mongo.local=false
unifi.db.name=${MONGO_DB}
_EOT_

    if [ "$MONGO_AUTH" = "true" ]
    then
        envsubst >>/system.properties <<_EOT_
db.mongo.uri=mongodb://${MONGO_USER}:${MONGO_PASS}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}
statdb.mongo.uri=mongodb://${MONGO_USER}:${MONGO_PASS}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}_stat
_EOT_

    else
        envsubst >>/system.properties <<_EOT_
db.mongo.uri=mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}
statdb.mongo.uri=mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}_stat
_EOT_
    fi

else
    cat >>/system.properties <<_EOT_
unifi.db.extraargs=--smallfiles
_EOT_

fi

: ${JAVA_Xmx:='256M'}
cat /system.properties >/usr/lib/unifi/data/system.properties
java -Xmx${JAVA_Xmx} -jar /usr/lib/unifi/lib/ace.jar start
