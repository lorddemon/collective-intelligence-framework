**Table of Contents**


# Introduction #

<font color='red'>
Upgrades are never an exact science, and generally are not recommended unless you have the time/skills to perform them if/when things fail. We do our best to provide the utilities and doc necessarily to cover edge cases, while this will improve over time, if something goes horribly bad, it might make more sense to start fresh with a new installation and new data. This is a learning process for the project and we don't currently have the resources to debug problems that might occur during a database upgrade.<br>
<br>
That being said, as long as you follow the directions carefully, backup your archive table (external usb-drives can be handy), you should be able to recover from a failed upgrade with out losing everything.<br>
<br>
If you do lose everything, ... it's not the end of the world, within a few weeks, your shinny new v1 instance will have lots of data in it to make lemonade with. :)<br>
</font>

  * v0.01, v0.02 instances (xml) are not supported
  * pre-v1.0.0instances are not supported

# Details #
From v0, the database upgrade primarily:

  * alters the apikeys tables
  * alters the archive table
  * drops the rest of the tables (un-needed in v1)
  * re-creates all the v1 tables around the archive table
  * converts the data in archive from json to compressed google protocol buffer blobs (v1 format)
  * re-populates the hash index table (used for searches)

## v0 ##

---

There are two ways to perform an upgrade, an **'in-place'** or **'new-installation'** upgrade. Both of these options take some time as we evolve our data formats. They require that the discrete steps are followed very carefully to avoid data corruption, etc.

### In-Place Upgrade ###

---

#### Overview ####
  * drops all v0 tables, with the exception of archive, apikeys and apikeys\_groups
  * alters the archive and apikeys tables to be compatible with v1
  * does NOT alter the archive and index tablespaces
  * creates the v1 tables around the archive table (in the index tablespace)
  * <font color='red'>EXPORT YOUR ARCHIVE TABLE TO A TEMPORARY DISK (lots of GB's)</font>
```
$ psql -U postgres -d cif
psql> COPY (select uuid,guid,format,created,data from archive WHERE format = 'iodef' AND description NOT LIKE '% feed') TO '/mnt/<my_big_drive>/cif.sql' WITH binary;
```
  * <font color='red'>BACKUP YOUR APIKEYS</font>
```
$ pg_dump -a -b --inserts -U postgres -t apikeys -t apikeys_groups cif > /tmp/cif_apikeys.sql
```
#### Prepare ####
  1. power down apache
  1. comment out / remove your old cif\_crontool crons and kill any existing running processes `(ps aux | grep cif_)`
  1. remove the v0 [client code](ClientRemoval_v0.md)
  1. re-name the old cif directory
```
$ sudo mv /opt/cif /opt/cif-v0
$ sudo mv /home/cif/.cif /home/cif/.cifv0
```
  1. generate a new cif (v1) config in /home/cif/.cif
  1. add the following as a template, if you have a client apikey from your v0 config, replace it in the client section where "apikey = XXXXX..."
```
[cif_archive]

# to enable asn, cc, rir datatypes (requires more storage)
# datatypes = infrastructure,domain,url,email,search,malware,cc,asn,rir
datatypes = infrastructure,domain,url,email,search,malware

# to enable feeds (requires more storage)
# feeds = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
# groups = everyone,group1.example.com,group2.example.com,group3.example.com

[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0

[cif_smrt]
# change localhost to your local domain and hostname respectively
# this identifies the data in your instance and ties it to your specific instance in the event
# that you start sharing with others
name = localhost
instance = cif.localhost

# the apikey for cif_smrt
apikey = XXXXXX-XXX-XXXX
```
  1. if you're using feeds, enable them in /home/cif/.cif
```
[cif_archive]
...
feeds = infrastructure,domain,url,email,search,malware
```
  1. add this section to end of the config
```
[cif_feed]
# max size of any feed generated
limit = 50000

# each confidence level to generate
confidence = 95,85,75,65

# what 'role' keys to use to generate the feeds
roles = role_everyone_feed

# how far back in time to generate the feeds from
limit_days = 7

# how many days of generated feeds to keep in the archive
feed_retention = 7
```
#### Upgrade ####
  1. upgrade system dependencies
    * (stable) [Debian 6](Upgrade_DebianSqueeze_v1.md)
    * (stable) [Debian 7](Upgrade_DebianWheezy_v1.md)
    * (stable) [Ubuntu 12](Upgrade_Ubuntu12_v1.md)
    * (stable) [CentOS6](Upgrade_CentOS6_v1.md)
  1. install the latest CIF [release](https://github.com/collectiveintel/cif-v1/releases) (be sure to pick the green-highlighted pre-built package, not the 'source')
```
$ tar -xzvf cif-v1-1.X.X.tar.gz
$ cd cif-v1-1.X.X
$ ./configure && make testdeps
$ sudo make install
```
  1. restart apache2
  1. upgrade the table structure (drop old tables, alter the archive/apikeys tables a bit, data migration happens below)
```
$ sudo make upgradedb
```
  1. generate a cif-smrt key to be used by cif\_smrt to submit data to the router and add it to the /home/cif/.cif under the 'cif\_smrt' section where 'apikey = XXXX...':
```
$ sudo su - cif
$ cif_apikeys -u cif_smrt -G everyone -g everyone -a -w
userid   key                                  description guid                                 default_guid restricted access write revoked expires created                      
cif_smrt bf1e0a9f-9518-409d-8e67-bfcc36dc5f44             8c864306-d21a-37b1-8705-746a786719bf true         0                 1                     2012-08-15 17:37:18.53348+00
$ logout
```
#### Data Migration ####
  1. run the upgrade-database utility that will convert the existing archive data into the new v1 format, as well as any feeds to be generated.
    * <font color='red'>if you haven't backed up the archive table, this is a good time to do it.</font>
    * this will take a very long time to run (hours, days depending on how much data you have)
    * if the process breaks, it keeps a journal (/tmp/cif-upgrade-database.journal) of where it left off and will re-start where it left off
```
$ cd libcif-dbi/
$ perl sbin/migrate-data.pl -t 4 -d -C /home/cif/.cif
```
  1. when this is completed, continue on to the [router setup](ServerInstall_v1#Router_Setup.md)

### New Installation Upgrade ###

---

  * this requires a new installation of v1 on a separate host
  * this requires a copy of the existing archive table file to be made available to the new installation
  * this option takes a little longer as a data-export / import is required
  * depending on the size of your archive tablespace, it could require extra temporary space to do the export (eg: a fast, external usb drive is handy in these cases if your network is too slow for moving large files around easily)
  * <font color='red'>MAKE SURE YOUR CLOCK TIMEZONE IS IN-SYNC (UTC) ACROSS BOTH HOSTS</font>

There are two ways to handle this type of upgrade:

  * cut off all services, run the upgrade, turn on all services
  * split the migration into two different exports, the first for the bulk of the historical data, the second for the data absorbed by the system from that point on

For a split migration, the dual-staged data-export will look something like:
```
$ psql -U postgres -d cif
psql> COPY (select uuid,guid,format,created,data from archive WHERE created <= '2012-06-01T23:59:59Z' AND format = 'iodef' AND description NOT LIKE '% feed') TO '/mnt/<my_large_disk>/cif.sql' WITH binary;
```

where the 'created' timestamp is a cutoff date sometime in the past (eg: "yesterday"). something easily pointed to in the next export for the official cutover:

```
$ psql -U postgres -d cif
psql> COPY (select uuid,guid,format,created,data from archive WHERE created > '2012-06-01T23:59:59Z' AND format = 'iodef' AND description NOT LIKE '% feed') TO '/mnt/<my_large_disk>/cif.sql' WITH binary;
```

#### Details ####
  1. follow the v1 [install](ServerInstall_v1.md) instructions until you get to the "Load Data" section
  1. import the archive copy to your current v1 database (could take a long time)
```
$ psql -U postgres -d cif
psql> COPY archive (uuid,guid,format,created,data) FROM '/mnt/<my_large_disk>/cif.sql' WITH binary;
```
  1. run the migrate-data utility that will convert the existing archive data into the new v1 format, as well as any feeds to be generated.
    * this will take a very long time to run (hours, days depending on how much data you have)
    * if the process breaks, it keeps a journal (/tmp/cif-upgrade-database.journal) of where it left off and will re-start where it left off
```
$ cd libcif-dbi/
$ perl sbin/migrate-data.pl -t 4 -d
```
  1. if you're doing this as a split process, repeat these steps with the new data (the process will remember where to start with the /tmp/cif-upgrade-database.journal file)

## v1-1.0.1 ##
If you're upgrading from v1.0.0-RC4 you need to update a the Net::DNS::Match, LWPx::paranoidAgent and Iodef::Pb::Simple dependencies.

  1. backup the old cif directory
```
$ sudo mv /opt/cif /opt/cif-v1.0.0
```
  1. update Net::DNS::Match, LWPx::paranoidAgent and Iodef::Pb::Simple
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Iodef::Pb::Simple, Net::DNS::Match, LWPx::ParanoidAgent,Net::Abuse::Utils'
```
  1. install the latest CIF [release](https://github.com/collectiveintel/cif-v1/releases) (be sure to pick the green-highlighted pre-built package, not the 'source')
```
$ tar -xzvf cif-v1-1.X.X.tar.gz
$ cd cif-v1-1.X.X
$ ./configure && make testdeps
```
  1. if 'make testdeps' succeeds, go a-head with the install, otherwise [walk through your OS/Disto guide for any missing libraries](ServerInstall_v1#Required_applications_and_dependencies.md)
  1. finish with the install
  1. be sure to copy any custom .cfg's from /opt/cif-v1.0.0/etc to your new /opt/cif/etc directory
```
$ sudo make install
```
  1. restart apache [and test](ServerInstall_v1#Router_Setup.md)

## v1-1.0.2 ##

  1. backup the old cif directory
```
$ sudo mv /opt/cif /opt/cif-v1.back
```
  1. install the latest CIF [v1.0.2-FINAL](https://github.com/collectiveintel/cif-v1/releases/tag/v1.0.2-FINAL) (be sure to pick the green-highlighted pre-built package, not the 'source')
```
$ tar -xzvf cif-v1-1.X.X.tar.gz
$ cd cif-v1-1.X.X
$ ./configure && make testdeps
```
  1. if 'make testdeps' succeeds, go a-head with the install, otherwise [walk through your OS/Disto guide for any missing libraries](ServerInstall_v1#Required_applications_and_dependencies.md)
  1. be sure Net::Abuse::Utils is up to date:
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Abuse::Utils'
```
  1. finish with the install
  1. be sure to copy any custom .cfg's from /opt/cif-v1.0.0/etc to your new /opt/cif/etc directory
```
$ sudo make install
```
  1. this upgrade requires the manual modification of one of the SQL tables
```
$ psql -U postgres -d cif
cif=# ALTER TABLE search RENAME COLUMN hash TO term;
cif=# ALTER TABLE search ALTER COLUMN term TYPE text;
cif=# \q
```
  1. restart apache [and test](ServerInstall_v1#Router_Setup.md)

## v1-1.0.3 ##
  1. <font color='red'>if you're upgrading from a version older than 1.0.2, be sure to follow that upgrade first</font>
  1. backup the old cif directory
```
$ sudo mv /opt/cif /opt/cif-v1.back
```
  1. install the latest CIF [v1.0.3-FINAL](https://github.com/collectiveintel/cif-v1/releases/tag/v1.0.3-FINAL) (be sure to pick the green-highlighted pre-built package, not the 'source')
```
$ tar -xzvf cif-v1-1.X.X.tar.gz
$ cd cif-v1-1.X.X
$ ./configure && make testdeps
```
  1. if 'make testdeps' succeeds, go a-head with the install, otherwise [walk through your OS/Disto guide for any missing libraries](ServerInstall_v1#Required_applications_and_dependencies.md)
  1. be sure Net::Abuse::Utils and Net::Abuse::Utils::Spamhaus is up to date:
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::DNS Net::Abuse::Utils Net::Abuse::Utils::Spamhaus'
```
  1. update Net::DNS (fixes some recent bugs)
```
$ sudo cpanm http://search.cpan.org/CPAN/authors/id/N/NL/NLNETLABS/Net-DNS-0.77.tar.gz
```
  1. finish with the install
  1. be sure to copy any custom .cfg's from /opt/cif-v1.0.2/etc to your new /opt/cif/etc directory
```
$ sudo make install
```
  1. restart apache [and test](ServerInstall_v1#Router_Setup.md)

## v1-1.0.4 ##

Follow the v1.0.3 instructions.