#!/bin/bash --debug

# this script will download and install the jetty version of atomhopper

function log {
  echo '[' `date` '] ' $1 >> install-ah.sh.log
  echo '[' `date` '] ' $1
}

JAVACMD=java
JAVACMD="/usr/libexec/java_home -v 1.7.0_79 --exec java"
CONF=h2

command_name=$0
function print_usage {
  echo "Usage: " `basename $command_name` "[ARG]..." 1>&2
  echo "where ARG can be zero or more of the following:" 1>&2
  echo "    -p|--proxy <proxy>        - specify an http proxy for downloads" 1>&2
  echo "    -g|--group <user:group>   - user:group (like chown) for jetty directories to use" 1>&2
  echo "" 1>&2
}

PROXY=
AHCHOWN=tomcat:tomcat

while [ ! -z "$1" ]; do
    case "$1" in

        --help)
            print_usage
            exit 0
            shift ;;

        -p|proxy|-proxy|--proxy)
	    PROXY=$2
            shift ;
            shift ;;

        -g|group|-group|--group)
            AHCHOWN=$2
            shift ;
            shift ;;

        *)
            echo "Unknown arg \"$arg\""
            print_usage
            exit 1
            shift ;;
    esac
done

echo "proxy=$PROXY chown=$AHCHOWN"

### calculate variables and urls
AH_FOLDER=ah-jetty-server
AH_EXT=jar
AH_BASE=$AH_FOLDER
AH_REPO_URL="https://maven.research.rackspacecloud.com/content/repositories/public/org/atomhopper/$AH_FOLDER"

if [ ! -z "$PROXY" ]; then 
  CURL_PROXY="--proxy $PROXY"
fi
AH_VERSION=`curl $CURL_PROXY -L -s $AH_REPO_URL/maven-metadata.xml | xpath '//release/text()' 2>/dev/null`

if [ "$AH_VERSION" == "" ]; then 
  export AH_VERSION="1.2.29"
fi
echo "Atomhopper version is $AH_VERSION"

AH_BASENAME=$AH_BASE-$AH_VERSION
AH_FILE="${AH_BASENAME}.jar"
AH_ARTIFACT_URL="$AH_REPO_URL/$AH_VERSION/$AH_FILE"

export MYIP=`/sbin/ifconfig | grep '\<inet\>' | grep -v '127.0.0.1' | awk '{print $2}' | sed 's/[^01-9\.]//g' | head -n 1`

### log the setup attempt
log "install-ah.sh - CONF=$CONF, AH_ARTIFACT_URL=$AH_ARTIFACT_URL"

$JAVACMD -jar jetty-killer.jar &>/dev/null    # shutdown any ah jetty
sleep 3
rm -f /var/log/atomhopper/jetty.log

### tear down any previous versions
# remove any jetty files

dirs="/etc/atomhopper /opt/atomhopper /var/log/atomhopper"

# delete left-over config files
for d in $dirs
do
  rm -rf $d
done

if [ ! -e $AH_FILE ]; then
  #wget -q $AH_ARTIFACT_URL
  curl $CURL_PROXY -O $AH_ARTIFACT_URL
fi

for d in $dirs 
do
  mkdir -p $d
  if [ ! -z "$AHCHOWN" ]; then
    chown -R $AHCHOWN $d
  fi
done

chmod 755 /opt/atomhopper

### copy config files
./copyFiles.sh $MYIP

# start up
if [ -e "$AH_FILE" ]; then
  $JAVACMD -jar $AH_FILE start &>/var/log/atomhopper/jetty.log &
else
  echo "Cannot find $AH_FILE."
  exit
fi


sleep 3
curl -s $MYIP:8080/namespace/feed
echo ""
echo ""

