#!/bin/bash

JAVACMD=java

PLATFORM=`uname`
if [ "$PLATFORM" == "Darwin" ]; then
  JAVACMD="/usr/libexec/java_home -v 1.7.0_79 --exec java"
fi

if [ "$1" == "" ]; then
  JARNAME=`find . -name "ah-jetty-server-*.jar"`
else
  JARNAME=$1
fi

if [ -e "$JARNAME" ]; then 

  $JAVACMD -jar "$JARNAME" start &>/var/log/atomhopper/jetty.log &

  sleep 3
  curl -s "localhost:8080/namespace/feed"
  echo ""
  echo ""
else 
  echo "Cannot find $JARNAME."
fi

