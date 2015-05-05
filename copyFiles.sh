#!/bin/bash
destpath="/etc/atomhopper"
cfgpath="./h2"
files="atom-server.cfg.xml application-context.xml context.xml log4j.properties"

HOST=$1
if [ "$HOST" == "" ]; then
  HOST="127.0.0.1"
fi

for f in $files
do
  if [ -e "$cfgpath/$f" ]; then
    echo "Copying "$cfgpath/$f" to $destpath/$f"
    sed -e "s/\${hostname}/$HOST/" "$cfgpath/$f" > "$destpath/$f"
    if [ "$?" -ne 0 ]; then 
      echo "$f errored with $?"
    fi 
  fi
done

