# Introduction #

Here we'll use the existing pg\_dump tool to backup your apikeys, apikeys\_groups and archive table. Note that this example does NOT include the index tables / tablespaces. These don't need to be backed up, they can be re-created using the /opt/cif/bin/cif\_indexer tool.

# Backup #
  * using the DROP TABLE option
```
$ pg_dump -U postgres -h localhost -c -v -a -Z 9 -f /tmp/cif_backup.sql.gz -t apikeys -t apikeys_groups -t archive cif
```
  * no DROP TABLE
```
$ pg_dump -U postgres -h localhost -v -a -Z 9 -f /tmp/cif_backup.sql.gz -t apikeys -t apikeys_groups -t archive cif
```

# Restore #
```
$ gzip -d /tmp/cif_backup.sql.gz -c | psql -U postgres -d cif
```

# References #
  * http://www.postgresql.org/docs/8.4/static/backup.html