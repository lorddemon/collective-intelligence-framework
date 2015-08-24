# Overview #
## Authors ##
  * Brad Shoop
  * Wes Young

## Since [10.04](ServerInstall_Ubuntu10.md) ##
  * libdigest-sha1-perl - deprecated, moved to libdigest-sha-perl
  * Class::LOAD::XS dependency
  * pkg-config dep

## Known Issues ##
  1. there's an issue with Ubuntu where Crypt::SSLeay might not install properly on some systems, if it fails, check out this [thread](http://colinnewell.wordpress.com/2011/10/24/cryptssleay-and-ubuntu-11-10/)

# Instructions #

  1. Install the base deps
```
$ sudo aptitude install rng-tools postgresql apache2 apache2-threaded-dev gcc make libexpat-dev libapache2-mod-perl2 libclass-dbi-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev libjson-perl rsync libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libhtml-table-perl libcrypt-ssleay-perl libdigest-sha-perl pkg-config
```
  1. Install the remaining CPAN modules
```
$ sudo perl -MCPAN -e 'install Class::Load::XS, LWP::Protocol::https, Net::Abuse::Utils,XML::Compile,XML::IODEF,XML::Malware,DateTime::Format::DateParse,Regexp::Common::net::CIDR,Apache2::REST,Text::Table,Linux::Cpuinfo,VT::API,Date::Manip,Try::Tiny'
```