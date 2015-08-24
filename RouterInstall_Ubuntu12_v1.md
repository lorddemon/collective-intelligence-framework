# Introduction #
This assumes a clean install of Ubuntu v12.04 with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Dependencies ##

---

  1. follow the [libcif-dbi](DbiInstall_Ubuntu12_v1.md) install instructions
  1. Install the following dependencies
```
$ sudo aptitude -y install apache2 apache2-threaded-dev libapache2-mod-perl2 libapache2-request-perl libapache2-mod-gnutls libapreq2-dev libapr1-dbg rng-tools
```

## System Setup ##
### CIF Router Configuration (Apache) ###

---

Some of the "CIF" values will be created later in the doc, for now just follow the config as is, don't worry about creating things like "/home/cif" etc.
  1. enable the default-ssl site (debian):
```
$ sudo a2ensite default-ssl
$ sudo a2enmod apreq
$ sudo a2enmod ssl
```
  1. unless you know what you're doing with virtual hosts, comment out the port-80 stuff in /etc/apache2/ports.conf
```
$ sudo vi /etc/apache2/ports.conf
```
```
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default
# This is also true if you have upgraded from before 2.2.9-3 (i.e. from
# Debian etch). See /usr/share/doc/apache2.2-common/NEWS.Debian.gz and
# README.Debian.gz

+ #NameVirtualHost *:80
+ #Listen 80

<IfModule mod_ssl.c>
    # If you add NameVirtualHost *:443 here, you will also have to change
    # the VirtualHost statement in /etc/apache2/sites-available/default-ssl
    ...
```
  1. configure apache2, add this line to your default-ssl site (or default if you're not using TLS)
```
$ sudo vi /etc/apache2/sites-available/default-ssl
```
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
+      PerlRequire /opt/cif/bin/http_api.pl
+      Include /etc/apache2/cif.conf
....
```
  1. create your config at /etc/apache2/cif.conf, which should look like:
```
$ sudo vi /etc/apache2/cif.conf
```
```
<Location /api>
    SetHandler perl-script
    PerlResponseHandler CIF::Router::HTTP
    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>

```
  1. add your "www-data" user (whoever apache is set to run under) to the group "cif" (/etc/group):
```
$ sudo adduser www-data cif
```
### Random Number Generator ###

---

The "rng-tools' service helps with random number generation (mainly used for generating security certificates in bind and apache, speeds up the entropy process).
  1. modify /etc/default/rng-tools to use /dev/urandom as the seed
```
$ echo 'HRNGDEVICE=/dev/urandom' | sudo tee -a /etc/default/rng-tools
```
  1. restart rng-tools
```
$ sudo service rng-tools restart
```
## Continue ##

---

  1. Continue with the cif-router [installation](RouterInstall_v1#Package.md)