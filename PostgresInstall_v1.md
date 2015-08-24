**Introduction**

This guide will show you how to setup an embedded instance of postgres using localhost. This config assumes you have trusted access to the instance from localhost.

**Table of Contents**

# Caveats #
Be sure to replace "X.X" with your version number of postgres in the example commands below. Debian 6.x and RHEL/CentOS 6 tend to run version 8.4 of postgres, Ubuntu will tend to come with version 9.x.
# Required Setup #
## Directory Permission Configuration ##

---

### Small Install ###
  1. Set the appropriate permissions:
```
$ sudo chown postgres:postgres /mnt/archive
$ sudo chown postgres:postgres /mnt/index
```
### Large Install ###
  1. Set the appropriate permissions:
```
$ sudo chown postgres:postgres /mnt/archive
$ sudo chown postgres:postgres /mnt/index
$ sudo chown postgres:postgres /mnt/pg_xlog
```
  1. Stop the postgresql service
  1. Link the pg\_xlog directory:
```
$ sudo mv /var/lib/postgresql/X.X/main/pg_xlog/* /mnt/pg_xlog/.
$ sudo rm -rf /var/lib/postgresql/X.X/main/pg_xlog
$ sudo ln -sf /mnt/pg_xlog /var/lib/postgresql/X.X/main/pg_xlog
```
  1. Restart the postgresql service

## Postgres Authentication Configuration ##

---

  1. Modify your postgres config accordingly (note the 'trust' setting, make sure your iptables are up to date!):
```
$ sudo vi /etc/postgresql/X.X/main/pg_hba.conf
```
```
 # (autovacuum, daily cronjob, replication, and similar tasks).
 #
 # Database administrative login by UNIX sockets
-local   all         postgres                          ident sameuser
+local   all         postgres                          trust 
 
 # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
 
 # "local" is for Unix domain socket connections only
-local   all         all                               ident sameuser
+local   all         all                               trust 
 # IPv4 local connections:
-host    all         all         127.0.0.1/32          md5
+host    all         all         127.0.0.1/32          trust
 # IPv6 local connections:
-host    all         all         ::1/128               md5
+host    all         all         ::1/128               trust
```

## Performance Configuration ##

---

**NOTE:** These recommend numbers have been tested on a machine with 4 cores and 8 GB of ram. During testing we found that these values may be too high for a machine with 4 GB of ram. If you are testing this on a machine with less than 8 GB of ram, you may want to skip this section all together or reduce the numbers these shell script spit out.

  1. Create backups of system files:
```
sudo cp /etc/sysctl.conf /etc/sysctl.conf.orig
sudo cp /etc/postgresql/X.X/main/postgresql.conf /etc/postgresql/X.X/main/postgresql.conf.orig
```
  1. create shmsetup.sh to configure:
    * shared memory  (to about 1/2 - 2/3 the amount of system ram)
    * control virtual memory overcommit and swappiness
```
$ vi shmsetup.sh
```
```
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
shmall=`expr $phys_pages / 2`
shmmax=`expr $shmall \* $page_size`
echo kernel.shmmax = $shmmax
echo kernel.shmall = $shmall
echo vm.overcommit_memory = 2
echo vm.swappiness = 0
# If you install CIF on a machine with limited ram and 
# have out of memory issues, uncomment the next line
#echo vm.overcommit_ratio = 100
```
  1. run the script
```
$ /bin/bash shmsetup.sh | sudo tee -a /etc/sysctl.conf
```
  1. reload the kernel settings
    * Debian / Ubuntu / RHEL 6.x
```
$ sudo sysctl -p
```
    * RHEL 5.x
```
$ sudo /sbin/sysctl -p
```
  1. Comment out existing shared\_buffers and max\_connections settings so it can be set below
```
sudo sed -i 's/shared_buffers/#shared_buffers/' /etc/postgresql/X.X/main/postgresql.conf
sudo sed -i 's/max_connections/#max_connections/' /etc/postgresql/X.X/main/postgresql.conf
```
  1. create postgressetup.sh to configure better defaults for your CIF installation
```
$ vi postgressetup.sh
```
```
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
total_ram_b=`expr $page_size \* $phys_pages`
total_ram_kb=`expr $total_ram_b / 1024`
total_ram_mb=`expr $total_ram_kb / 1024`
ten_percent_total_ram=`expr $total_ram_mb / 10`

work_mem=`expr $total_ram_mb / 8`
shared_buffers=$ten_percent_total_ram
effective_cache_size=`expr $ten_percent_total_ram \* 6`

echo ""
echo ""
echo "#------------------------------------------------------------------------------"
echo "# CIF Setup                                                                    "
echo "#------------------------------------------------------------------------------"
echo "# Rough estimates on how to configured postgres to work with large data sets"
echo "# See the following URL for proper postgres performance tuning"
echo "# http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server"
echo "wal_buffers = 12MB" " # recommended range for this value is between 2-16MB"
echo "work_mem = $work_mem""MB" " # minimum 512MB needed for cif_feed"
echo "shared_buffers = $shared_buffers""MB" "# recommended range for this value is 10% on shared db server"
echo "checkpoint_segments = 10" " # at least 10, 32 is a more common value on dedicated server class hardware"
echo "effective_cache_size = $effective_cache_size""MB" " # recommended range for this value is between 60%-80% of your total available RAM"
echo "max_connections = 8" " # limiting to 8 due to high work_mem value"
```
  1. run the script
```
$ /bin/bash postgressetup.sh | sudo tee -a /etc/postgresql/X.X/main/postgresql.conf
```
## Testing ##

---

  1. restart postgres
    * Debian
```
sudo /etc/init.d/postgresql restart
```
    * Ubuntu/RHEL
```
$ sudo service postgresql restart
```
  1. make sure your user can log in:
```
$> psql -U postgres
```
```
postgres=#
postgres=#\l
                                 List of databases
   Name    |  Owner   | Encoding | Collation  |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres
                                                           : postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres
                                                           : postgres=CTc/postgres
(3 rows)
postgres=#\q
```
  1. if you have issues logging in, it's typically because of a bad pg\_hba.conf file, double check your config and reload postgres.

# Optional Setup #
## Disk Write Performance ##

---

  1. **EXPERIMENTAL** check your blockdev setting in rc.local:
```
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-archive
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-index
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-dbsystem
```

# Continue with configuration #

---

Continue with the [Installing CIF](ServerInstall_v1#Installing_CIF.md)

# Helpful References #

---

  1. [Five Steps to PostgresSQL Performance](http://www.pgexperts.com/document.html?id=36)
  1. [Tuning a Linux system for Database Server](http://www.randombugs.com/linux/tuning-linux-system-database.html)
  1. [Book: PostgreSQL 9.0 High Performance](http://www.amazon.com/PostgreSQL-High-Performance-Gregory-Smith/dp/184951030X/ref=sr_1_1?ie=UTF8&qid=1321356392&sr=8-1)
  1. [Managing Kernel Resources](http://developer.postgresql.org/pgdocs/postgres/kernel-resources.html)
  1. [PostgreSQL Hardware Performance Tuning](http://momjian.us/main/writings/pgsql/hw_performance/)
  1. [Performance Tuning PostgreSQL](http://www.revsys.com/writings/postgresql-performance.html)
  1. [15 Advanced PostgreSQL Commands with Examples](http://www.thegeekstuff.com/2009/05/15-advanced-postgresql-commands-with-examples/)
  1. [PostgreSQL: Tuning Your PostgreSQL Server](http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)
  1. [PostgreSQL: FAQ](http://wiki.postgresql.org/wiki/FAQ)
  1. [PostgreSQL: Disk Usage](http://wiki.postgresql.org/wiki/Disk_Usage)