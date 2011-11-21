#!/bin/bash
make clean
rm MANIFEST
perl Makefile.PL
make manifest
make dist
cp RT-*.gz ../
