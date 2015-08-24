<font color='red'>
<h1>Unstable</h1>
</font>

# Introduction #

**Table of Contents**


## Preamble ##

---

For the purpose of this document, it is assumed that the IP address of cif-router is 10.0.0.2.

## Disk Layout ##

---

Consult the Disk Layout Guide before setting up your operating system. There are implications as to how this is done based on which type of install is opted for. Larger install's with LVM require a bit more configuration than a small install.

  1. [Disk Layout Guide](DiskLayout_v1.md)

### Additional Disk Configuration ###
Some additional directories need to be created, otherwise when the CIF DB creation script is ran from the primary server, the DB will not be properly created.

```
$ mkdir -p /mnt/{archive,index}/data
$ chown postgres:postgres /mnt/{archive,index}/data
```

## Install Required Dependencies ##

---

  * (unstable) Debian Squeeze
  * (unstable) Ubuntu 12.04
```
$ sudo aptitude -y install postgresql
```
  * (unstable) CentOS6

## Postgres configuration ##

---

### Postgres ###
Configure Postgres authentication and performance tuning
  1. [PostgresSetup](PostgresInstall_v1.md)

### Additional Postgres Configuration ###
Configure Postgres to accept connections from a host running cif-router.

  1. Configure iptables to allow access to port 5432 from cif-router (10.0.0.2).
  1. Add the IP address of cif-router  to pg\_hba.conf.
```
$ sudo vi /etc/postgresql/X.X/main/pg_hba.conf
```
```
 # IPv4 local connections:
+host	 all	     all	 10.0.0.2/32	       trust
```
  1. Modify the postgresql service so that it is listening for IP based connections
```
$ sudo vi /etc/postgresql/X.X/main/postgresql.conf
```
```
-listen_addresses = 'localhost'
+listen_addresses = '*'
```