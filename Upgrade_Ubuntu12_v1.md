# Introduction #
This assumes a clean install of Ubuntu 12 with sudo, all base system updates applied and a base v0 CIF installation.

**Table of Contents**


# Details #
## Dependencies Installation ##

---

  1. make sure aptitude is up to date
```
$ sudo aptitude update
```
  1. Install the base dependencies from the Ubuntu repositories (as root)
```
$ aptitude -y install rng-tools build-essential postgresql apache2 apache2-threaded-dev gcc g++ make libexpat1-dev libapache2-mod-perl2 libclass-dbi-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev rsync libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config vim libjson-xs-perl perl-modules libdigest-sha-perl libsnappy-dev libdatetime-format-dateparse-perl liblwp-protocol-https-perl libtime-hires-perl libnet-patricia-perl libnet-ssleay-perl liblog-dispatch-perl libregexp-common-net-cidr-perl libtext-table-perl libdatetime-perl libencode-perl libmime-base64-perl libhtml-table-perl libzmq-dev libzmq1 libzeromq-perl libssl-dev
```
  1. Install the remaining perl dependencies from CPAN (as root)
```
$ PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Test::SharedFork,Test::TCP,Net::Abuse::Utils,Linux::Cpuinfo,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Net::Abuse::Utils::Spamhaus,Net::DNS::Match,Snort::Rule,Parse::Range,Log::Dispatch,Net::SSLeay,ZeroMQ,Sys::MemInfo,LWP::Protocol::https,LWPx::ParanoidAgent'
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
-    PerlRequire /opt/cif/bin/webapi.pl
+   PerlRequire /opt/cif/bin/http_api.pl
      Include /etc/apache2/cif.conf
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
