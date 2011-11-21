#!/bin/bash

SITE=$1
SITE=$(echo $SITE | tr "[:lower:]" "[:upper:]")
SITE=SITE_$SITE

SCRIPT=/opt/rt3/local/plugins/RT-IR/etc/add_constituency

$SCRIPT --name $SITE
