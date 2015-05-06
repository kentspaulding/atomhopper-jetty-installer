#!/bin/bash

JAVACMD=java

# stop jetty
if [ "$1" == "" ]; then
  JARNAME="jetty-killer.jar"
else
  JARNAME="$1"
fi

if [ -e "$JARNAME" ]; then 
  $JAVACMD -jar $JARNAME
  sleep 3
  rm /var/log/atomhopper/jetty.log
  curl "localhost:8080/namespace/feed"
else 
  echo "Cannot find $JARNAME."
  exit
fi

