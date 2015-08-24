
# Introduction #

This guide will show you how to setup an embedded instance of postgres using localhost. This config assumes you have trusted access to the instance from localhost. CIF v0.02 assumes this to be an embedded database and there is no way to access a database outside of the localhost. This will be addressed in future versions (v1).

Before you begin, you should consult the [DiskLayout\_v0](DiskLayout_v0.md) page for optimum database performance.

# Details #
## Setup ##
  1. Modify your postgres config
```
$ diff -u pg_hba.conf.orig pg_hba.conf
--- pg_hba.conf.orig	2010-09-02 12:06:29.000000000 +0000
+++ pg_hba.conf	2010-09-02 12:21:43.000000000 +0000
@@ -71,13 +71,13 @@
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
  1. reload postgres
  1. make sure your user can:
```
$> psql -U postgres
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
## Performance Tuning ##
  1. create shmsetup.sh to configure your shared memory  (to about 1/2 - 2/3 the amount of system ram:
```
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
shmall=`expr $phys_pages / 2`
shmmax=`expr $shmall \* $page_size`
echo kernel.shmmax = $shmmax
echo kernel.shmall = $shmall
```
  1. run the script
```
$ sudo ./shmsetup.sh >> /etc/sysctl.conf
```
  1. control virtual memory overcommit and swappiness
```
$ sudo echo vm.overcommit_memory = 2 >> /etc/sysctl.conf
$ sudo echo vm.swappiness = 0 >> /etc/sysctl.conf
```
  1. reload the kernel settings
```
$ sudo sysctl -p
```
  1. set the following values in postgresql.conf:
```
wal_buffers = 16MB
work_mem = 1GB # 25% of total ram
shared_buffers = 1GB # 25% of total ram
checkpoint_segments = 32 # For more write-heavy systems, values from 32 (checkpoint every 512MB) to 256 (every 4GB) are popular nowadays. see: http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server for more info
effective_cache_size = 1GB    # whatever you set shmmax to
```
  1. restart postgres
```
$ sudo /etc/init.d/postgresql restart
```

## Optional Tweaks ##
  1. **EXPERIMENTAL** check your blockdev setting in rc.local:
```
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-archive
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-index
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-dbsystem
```

## References ##
  1. http://www.amazon.com/PostgreSQL-High-Performance-Gregory-Smith/dp/184951030X/ref=sr_1_1?ie=UTF8&qid=1321356392&sr=8-1
  1. http://developer.postgresql.org/pgdocs/postgres/kernel-resources.html
  1. http://momjian.us/main/writings/pgsql/hw_performance/
  1. http://www.revsys.com/writings/postgresql-performance.html
  1. http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server
  1. http://wiki.postgresql.org/wiki/FAQ
  1. http://www.thegeekstuff.com/2009/05/15-advanced-postgresql-commands-with-examples/
  1. http://wiki.postgresql.org/wiki/Disk_Usage