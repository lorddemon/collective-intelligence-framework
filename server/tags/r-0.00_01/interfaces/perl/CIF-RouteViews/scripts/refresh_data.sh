#!/bin/bash

python asn_get_routeviews.py | perl rv_insert.pl
