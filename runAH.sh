#!/bin/bash

JAVACMD=java
JAVACMD="/usr/libexec/java_home -v 1.7.0_79 --exec java"

# start up
if [ -e "$1" ]; then
  $JAVACMD -jar $1 start &>/var/log/atomhopper/jetty.log &
else
  echo "Cannot find $1."
  exit
fi

sleep 3
curl -s localhost:8080/namespace/feed

