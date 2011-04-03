#!/bin/bash

DB="cif"
SCHEMA="deps.sql domain.sql infrastructure.sql malware.sql url.sql email.sql feed.sql"

cd schemas/psql
for S in $SCHEMA; do
    psql -q -U postgres -d $DB < $S
done
