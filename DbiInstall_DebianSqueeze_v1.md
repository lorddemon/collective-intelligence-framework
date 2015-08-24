# Introduction #
This doc provides for the installation of a remote database client (eg: the router, or an apikeys interface manager). This doc assumes:
  * a clean install of Debian Squeeze (v6.0.x) with sudo and all base system updates applied.
  * the database instance (physical data) is located on a different set of resources

**Table of Contents**


# Details #
## Dependencies Installation ##

---

  1. install the [client](ClientInstall_v1.md)
  1. install the base deps
```
$ sudo aptitude -y install postgresql-client libclass-dbi-perl libdbd-pg-perl
```
  1. Install the remaining CPAN modules
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::DNS::Match'
```
  1. continue with the [install](DbiInstall_v1#Install_Library.md)