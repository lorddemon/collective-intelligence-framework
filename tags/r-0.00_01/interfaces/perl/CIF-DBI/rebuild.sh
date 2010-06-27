#!/bin/bash

make realclean
rm *.tar.gz
rm MANIFEST
perl Makefile.PL
make manifest
make dist
