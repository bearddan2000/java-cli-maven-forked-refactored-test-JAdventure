#!/usr/bin/env bash

BASEFILE="install"
LOGFILE="general.log"

if [ "$#" -ne 1 ]; then
  msg="[ERROR]: $BASEFILE failed to receive enough args"
  echo "$msg"
  echo "$msg" >> $LOGFILE
  exit 1
fi

function setup-logging(){
  local scope="setup-logging"
  local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

  echo "$info_base started" >> $LOGFILE

  echo "$info_base removing old logs" >> $LOGFILE

  rm -f $LOGFILE

  echo "$info_base ended" >> $LOGFILE

  echo "================" >> $LOGFILE
}

function root-check(){
  local scope="root-check"
  local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

  echo "$info_base started" >> $LOGFILE

  #Make sure the script is running as root.
  if [ "$UID" -ne "0" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S') ERROR]: $BASEFILE::$scope you must be root to run $0" >> $LOGFILE
    echo "==================" >> $LOGFILE
    echo "You must be root to run $0. Try the following"
    echo "sudo $0"
    exit 1
  fi

  echo "$info_base ended" >> $LOGFILE
  echo "================" >> $LOGFILE
}

function docker-check() {
  local scope="docker-check"
  local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"
  local cmd=`docker -v`

  echo "$info_base started" >> $LOGFILE

  if [ -z "$cmd" ]; then
    echo "$info_base docker not installed"
    echo "$info_base docker not installed" >> $LOGFILE
  fi

  echo "$info_base ended" >> $LOGFILE
  echo "================" >> $LOGFILE

}
function usage() {
    echo ""
    echo "Usage: "
    echo ""
    echo "-u: start."
    echo "-d: tear down."
    echo "-h: Display this help and exit."
    echo ""
}
function decompress() {
    local scope="decompress"
    local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

    echo "$info_base started" >> $LOGFILE

    local filename=$1

    local decompressed_folder=$2

    if [[ -d "$dir" ]]; then

          echo "$info_base $filename already decompressed" >> $LOGFILE

          echo "$info_base ended" >> $LOGFILE

          echo "================" >> $LOGFILE

          return
    fi

    echo "$info_base decompress $filename " >> ../$LOGFILE

    sudo tar -xf $filename

    echo "$info_base removing $filename " >> ../$LOGFILE

    sudo rm -f $filename

    echo "$info_base ended" >> $LOGFILE

    echo "================" >> $LOGFILE
}
function compress() {
    local scope="compress"
    local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

    echo "$info_base started" >> $LOGFILE

    local filename=$1

    local decompressed_folder=$2

    if [[ -f "$filename" ]]; then

          echo "$info_base $decompressed_folder already compressed" >> $LOGFILE

          echo "$info_base ended" >> $LOGFILE

          echo "================" >> $LOGFILE

          return
    fi

    echo "$info_base compressing $decompressed_folder " >> ../$LOGFILE

    sudo tar -czvf $filename $decompressed_folder

    echo "$info_base removing $decompressed_folder " >> ../$LOGFILE

    sudo rm -Rf $decompressed_folder

    echo "$info_base ended" >> $LOGFILE

    echo "================" >> $LOGFILE
}

function start-up(){

    local scope="start-up"
    local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

    echo "$info_base started" >> $LOGFILE

    decompress "bin.tar.gz" "bin"

    echo "$info_base starting services" >> $LOGFILE

    docker run -it --rm --name mvn-test \
    -v $(pwd)/bin:/usr/src/mymaven \
    -w /usr/src/mymaven \
    maven:3-openjdk-17 \
    mvn clean test -P feature

    echo "$info_base ended" >> $LOGFILE

    echo "================" >> $LOGFILE
}
function tear-down(){

    local scope="tear-down"
    local info_base="[$(date '+%Y-%m-%d %H:%M:%S') INFO]: $BASEFILE::$scope"

    echo "$info_base started" >> $LOGFILE

    compress "bin.tar.gz" "bin"

    echo "$info_base starting services" >> $LOGFILE

    echo "$info_base ended" >> $LOGFILE

    echo "================" >> $LOGFILE
}

root-check
docker-check

while getopts ":udh" opts; do
  case $opts in
    u)
      setup-logging
      start-up ;;
    d)
      tear-down ;;
    h)
      usage
      exit 0 ;;
    /?)
      usage
      exit 1 ;;
  esac
done
