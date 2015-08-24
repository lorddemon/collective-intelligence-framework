# Introduction #
This doc provides for the installation of a remote database client (eg: the router, or an apikeys interface manager). This doc assumes:
  * a clean install of CentOS6 with sudo and all base system updates applied.
  * the database instance (physical data) is located on a different set of resources

**Table of Contents**


# Details #
## Caveats ##
## Dependencies Installation ##

---

  1. install the [client](ClientInstall_v1.md)
  1. install the dependencies (as root)
```
$ yum -y install postgresql
```
## System Setup ##

---

### Default CIF user ###

---

  1. create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser cif
```
  1. change the default home permissions
```
$ sudo chmod 770 /home/cif
```
  1. continue with the [install](DbiInstall_v1#Install_Library.md)