#!/bin/bash

DB="cif"
SCHEMA="messages.sql domain.sql inet.sql malware.sql phishing_replyto.sql url.sql"

psql -U postgres -c "DROP DATABASE $DB"
psql -U postgres -c "CREATE DATABASE $DB"

cd schemas/psql
for S in $SCHEMA; do
    psql -U postgres -d $DB < $S
done
