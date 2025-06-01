#!/bin/bash
set -e

# Usage: mariadb_start.sh stop|0:1 clusterwait|0:1
STOP=$1
CLUSTERWAIT=$2
MAX_DURATION=1800
DELAY=10
CHANGED=0

if [ "$STOP" = "1" ] ; then
  # Make sure mariadb is stopped
  CHANGED=1
  systemctl stop mariadb
fi

# Start it
if ! systemctl is-active mariadb ; then
  CHANGED=1
  systemctl start mariadb
fi

if [ "$CLUSTERWAIT" = "1" ] ; then
  start=`date +%s`
  sleep ${DELAY}
  while ! /usr/local/bin/clustercheck > /dev/null ; do
    if ! systemctl is-active mariadb > /dev/null ; then
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

if [ "$CHANGED" = "1" ] ; then
  echo "changed"
fi

exit 0
