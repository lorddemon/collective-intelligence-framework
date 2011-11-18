#!/bin/bash

FEDERATION=$1
FEDERATION=$(echo $FEDERATION | tr "[:lower:]" "[:upper:]")
FEDERATION=FEDERATION_$FEDERATION

SCRIPT=/opt/rt3/local/plugins/RT-IR/etc/add_constituency

$SCRIPT --name $FEDERATION
