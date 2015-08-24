# Introduction #
This assumes a clean install of Debian Squeeze (v6.0.x) with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Dependencies ##

---

  1. install the [client](ClientInstall_v1.md)
  1. Install the following dependencies
```
$ sudo aptitude -y install libexpat-dev libnet-cidr-perl libxml-libxml-perl libxml2-dev libmodule-install-perl bind9 libregexp-common-perl libxml-rss-perl libunicode-string-perl libconfig-simple-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libhtml-table-perl libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config libnet-ssleay-perl vim libjson-xs-perl libextutils-parsexs-perl libdatetime-format-dateparse-perl libnet-patricia-perl libdatetime-perl libtext-table-perl
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
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Abuse::Utils,Linux::Cpuinfo,Time::HiRes,Net::Abuse::Utils::Spamhaus,Net::SSLeay,Sys::MemInfo,ZeroMQ'
```
## System Setup ##

---

### Bind9 Setup ###
  1. configure [bind](BindSetup_v1.md)

### Resolver Config ###
Configure the static interface to use 127.0.0.1 as the nameserver.

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
  1. Continue with the cif-smrt [installation](SmrtInstall_v1#Install_Package.md)