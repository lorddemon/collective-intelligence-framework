#!/bin/bash

DB="cif"
SCHEMA="message.sql domain.sql infrastructure.sql malware.sql url.sql email.sql feed.sql"

psql -U postgres -c "DROP DATABASE $DB"
psql -U postgres -c "CREATE DATABASE $DB"

cd schemas/psql
for S in $SCHEMA; do
    psql -q -U postgres -d $DB < $S
done
