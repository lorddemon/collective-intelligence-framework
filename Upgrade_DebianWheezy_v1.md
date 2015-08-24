# Introduction #
This assumes a clean install of Debian Squeeze (v7.0.x) with sudo, all base system updates applied and a base v0 CIF installation.

**Table of Contents**


# Details #
## Dependencies Installation ##

---

  1. make sure aptitude is up to date
```
$ sudo aptitude update
```
  1. Install the base deps
```
$ sudo aptitude -y install rng-tools postgresql apache2 apache2-threaded-dev gcc g++ make libexpat-dev libapache2-mod-perl2 libclass-dbi-perl libdigest-sha1-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev rsync libunicode-string-perl libconfig-simple-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libhtml-table-perl libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config libnet-ssleay-perl vim libjson-xs-perl libextutils-parsexs-perl libdatetime-format-dateparse-perl libnet-patricia-perl libdatetime-perl libtext-table-perl
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
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Module::Build,Test::SharedFork,Test::TCP,Net::Abuse::Utils,Regexp::Common::net::CIDR,Linux::Cpuinfo,LWP::Protocol::https,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Snort::Rule,Time::HiRes,Net::Abuse::Utils::Spamhaus,Net::SSLeay,Net::DNS::Match,Log::Dispatch,Sys::MemInfo,LWPx::ParanoidAgent,ZeroMQ'
```

## Router Configuration (Apache) ##

---

  1. modify your apache site settings
```
$ sudo vi /etc/apache2/sites-available/default-ssl
```
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
-      PerlRequire /opt/cif/bin/webapi.pl
+     PerlRequire /opt/cif/bin/http_api.pl
+     Include /etc/apache2/cif.conf
....
```
  1. modify your apache cif config
```
sudo vi /etc/apache2/cif.conf
```
```
<Location /api>
-    SetHandler perl-script
-    PerlSetVar Apache2RESTHandlerRootClass "CIF::WebAPI::Plugin"
-    PerlSetVar Apache2RESTAPIBase "/api"
-    PerlResponseHandler Apache2::REST
-    PerlSetVar Apache2RESTWriterDefault 'json'
-    PerlSetVar Apache2RESTAppAuth 'CIF::WebAPI::AppAuth'
-
-    # feed defaults
-    PerlSetVar CIFLookupLimitDefault 500
-    PerlSetVar CIFDefaultFeedSeverity "high"
-
-    # extra outputs
-    PerlAddVar Apache2RESTWriterRegistry 'table'
-    PerlAddVar Apache2RESTWriterRegistry 'CIF::WebAPI::Writer::table'

+    SetHandler perl-script
+    PerlResponseHandler CIF::Router::HTTP
+    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>
```
  1. restart apache2

Continue with the [upgrade](Upgrade_v1#Upgrade.md)

---
