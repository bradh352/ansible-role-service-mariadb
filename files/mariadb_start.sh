#!/bin/bash
set -e

# Usage: mariadb_start.sh stop|0:1 clusterwait|0:1
STOP=$1
CLUSTERWAIT=$2
MAX_DURATION=1800
DELAY=10

if [ "$STOP" = "1" ] ; then
  # Make sure mariadb is stopped
  systemctl stop mariadb
fi

# Start it
systemctl start mariadb

if [ "$CLUSTERWAIT" = "1" ] ; then
  start=`date +%s`
  sleep ${DELAY}
  while ! /usr/local/bin/clustercheck > /dev/null ; do
    if [ ! systemctl is-active mariadb > /dev/null ] ; then
      echo "MariaDB unexpectedly quit"
      exit 1
    fi
    curr=`date +%s`
    let "duration = curr - start"
    if [ $duration -gt $MAX_DURATION ] ; then
      echo "Took too long to start"
      exit 1
    fi
    sleep ${DELAY}
  done
fi

exit 0
