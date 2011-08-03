#!/bin/bash

rm -R -f /tmp/cifsearch.xpi
zip -x package.sh -x *.svn* -r /tmp/cifsearch.xpi ./
cp /tmp/cifsearch.xpi ~/Desktop/
