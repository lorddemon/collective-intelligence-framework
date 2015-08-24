# Introduction #
This assumes a clean install of Debian Wheezy (v7.x) with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Caveats ##
### Minimal Debian ###
  1. make sure apt is up to date
```
# aptitude update && aptitude safe-upgrade
```
  1. minimal Debian does not come with sudo. If you used the net boot version of the debian installer, you'll need to install this as root:
```
# aptitude install sudo
```
### Static Address ###
Make sure your instance has a static v4 address
### ZeroMQ 2.x ###
There are two different tree's in the zeromq family, 2.x and 3.x, CIF v1 leverages the 2.x family right now. Future versions may be built against the CZMQ api and may be built against either code base. The instructions below will take care of the installation.
## Dependencies Installation ##

---

  1. Install the base deps
```
$ sudo aptitude -y install rng-tools postgresql apache2 apache2-threaded-dev gcc g++ make libexpat1-dev libapache2-mod-perl2 libclass-dbi-perl libdigest-sha-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev rsync libunicode-string-perl libconfig-simple-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libhtml-table-perl libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config libnet-ssleay-perl vim libjson-xs-perl libextutils-parsexs-perl libdatetime-format-dateparse-perl libnet-patricia-perl libdatetime-perl libtext-table-perl libcpan-meta-perl libmodule-build-perl
```
  1. Install zeromq-2.2.0 from source
```
$ wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
$ tar -zxvf zeromq-2.2.0.tar.gz
$ cd zeromq-2.2.0
$ ./configure && make && sudo make install
$ sudo ldconfig
```
  1. Install the remaining CPAN modules
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Test::SharedFork,Test::TCP,Net::Abuse::Utils,Regexp::Common::net::CIDR,LWP::Protocol::https,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Snort::Rule,Time::HiRes,Net::Abuse::Utils::Spamhaus,Net::SSLeay,Net::DNS::Match,Log::Dispatch,Sys::MemInfo,LWPx::ParanoidAgent,ZeroMQ,Net::Whois::IP,Net::DNS,Email::Address'
```
  1. Linux::Cpuinfo needs to be installed manually due to a signature bug
```
$ wget http://search.cpan.org/CPAN/authors/id/J/JS/JSTOWE/Linux-Cpuinfo-1.7.tar.gz
$ tar -zxvf Linux-Cpuinfo-1.7.tar.gz
$ cd Linux-Cpuinfo-1.7
$ perl Makefile.PL && make && sudo make install
```

## System Setup ##

---

### Resolver Config ###
Configure the static interface to use 127.0.0.1 as the nameserver. Bind will be configured next.

  1. edit /etc/network/interfaces
```
$ sudo vi /etc/network/interfaces
```
  1. replace (or add) dns-nameservers with 127.0.0.1
```
# The primary network interface
iface eth0 inet
        dns-nameservers 127.0.0.1
```
  1. edit /etc/resolv.conf
```
$ sudo vi /etc/resolv.conf
```
  1. replace (or add) nameserver with 127.0.0.1
```
nameserver 127.0.0.1
```
  1. Restart networking
```
$ sudo ifdown eth0 && sudo ifup eth0
```

### Default CIF user ###

---

Create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser --disabled-password --gecos '' cif
```
### CIF Router Configuration (Apache) ###

---

Some of the "CIF" values will be created later in the doc, for now just follow the config as is, don't worry about creating things like "/home/cif" etc.
  1. enable the default-ssl site (debian):
```
$ sudo a2ensite default-ssl
$ sudo a2enmod ssl perl apreq
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
sudo vi /etc/apache2/cif.conf
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
$ sudo /etc/init.d/rng-tools restart
```
## Continue ##

---

Continue with [Bind configuration](ServerInstall_v1#Bind.md)