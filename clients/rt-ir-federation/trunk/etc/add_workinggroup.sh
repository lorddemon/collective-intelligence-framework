#!/bin/bash

VAR=$1
VAR=$(echo $VAR | tr "[:lower:]" "[:upper:]")
VAR=WORKINGGROUP_$VAR

SCRIPT=/opt/rt3/local/plugins/RT-IR/etc/add_constituency

$SCRIPT --name $VAR
