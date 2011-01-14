#!/bin/bash

set -e

CRON=$1

case $CRON in
    '')
    echo 'hourly,daily,weekly argument required'
    exit
    ;;
esac

CONFIG="/etc/cif/cron_$CRON"
CRONS=`cat $CONFIG`

for SCRIPT in $CRONS
do
   perl $SCRIPT
done
