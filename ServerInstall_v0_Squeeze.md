Squeeze Server Install

  1. Install the base deps
```
$ sudo aptitude install rng-tools postgresql apache2 apache2-threaded-dev gcc make libexpat-dev libapache2-mod-perl2 libclass-dbi-perl libdigest-sha1-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev libjson-perl rsync libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libhtml-table-perl libdate-manip-perl
```
  1. Install the remaining CPAN modules
```
$ sudo perl -MCPAN -e 'install Net::Abuse::Utils,XML::Compile,XML::IODEF,XML::Malware,DateTime::Format::DateParse, Regexp::Common::net::CIDR,Apache2::REST,Text::Table,Linux::Cpuinfo,VT::API,LWP::Protocol::https,Try::Tiny'
```