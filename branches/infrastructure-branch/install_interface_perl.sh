#!/usr/bin/bash

cd interfaces/perl/CIF-DBI
perl Makefile.PL
make
make test
sudo make install
