#!/bin/bash

DB="cif"
SCHEMA="archive.sql"

psql -U postgres -c "DROP DATABASE $DB"
psql -U postgres -c "CREATE DATABASE $DB"

cd schemas/psql
for S in $SCHEMA; do
    psql -q -U postgres -d $DB < $S
done
