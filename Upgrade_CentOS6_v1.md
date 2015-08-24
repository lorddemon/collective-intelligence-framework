# Introduction #
This assumes a clean install of CentOS6 with sudo, all base system updates applied and a base v0 CIF installation.

**Table of Contents**


# Details #
## Dependencies Installation ##

---

  1. install base server dependencies (as root) first
```
$ yum -y install sudo bind-utils rng-tools postgresql-server httpd httpd-devel mod_ssl gcc make expat expat-devel uuid uuid-devel wget bind rsync libuuid-devel mod_perl mod_perl-devel ntpdate
```
  1. make sure your clock is up to date (some packages might not install if it's too far skewed)
```
$ sudo ntpdate -u pool.ntp.org
```
  1. import the fedoraproject EPEL-6 gpg key
```
$ sudo rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
```
  1. install some 3rd party dependencies
```
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-2.13-1.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-devel-2.13-1.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/perl-libapreq2-2.13-1.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-2.2.0-4.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-devel-2.2.0-4.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/openpgm-5.1.118-3.el6.x86_64.rpm
$ sudo rpm -iv openpgm-5.1.118-3.el6.x86_64.rpm
$ sudo rpm -iv libapreq2-2.13-1.el6.x86_64.rpm libapreq2-devel-2.13-1.el6.x86_64.rpm perl-libapreq2-2.13-1.el6.x86_64.rpm zeromq-2.2.0-4.el6.x86_64.rpm zeromq-devel-2.2.0-4.el6.x86_64.rpm
```
  1. install the baseline perl modules
```
$ sudo yum -y install perl-Digest-SHA libxml2 libxml2-devel perl-XML-LibXML perl-DBD-Pg perl-XML-RSS perl-JSON perl-Unicode-String perl-Config-Simple perl-Module-Pluggable perl-MIME-Lite perl-CPAN perl-Class-Accessor perl-YAML perl-XML-Parser uuid-perl perl-Net-DNS perl-DateTime-Format-DateParse perl-IO-Socket-INET6 openssl-devel perl-Module-Install perl-Net-SSLeay perl-Class-Trigger perl-Date-Manip perl-IO-Socket-SSL
```
  1. install the remaining CPAN modules (PERL\_MM\_USE\_DEFAULT=1 will auto "yes" to the prompts)
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Module::Build,Test::SharedFork,Test::TCP,Net::Abuse::Utils,Linux::Cpuinfo,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Net::Abuse::Utils::Spamhaus,Net::DNS::Match,Snort::Rule,Parse::Range,Log::Dispatch,ZeroMQ,Sys::MemInfo,JSON::XS,File::Type,LWP::UserAgent,Class::Trigger,Class::DBI,Net::Patricia,Text::Table,Mozilla::CA,IO::Socket::SSL,IO::Socket::INET6,LWP::Protocol::https,Text::CSV,XML::RSS,LWPx::ParanoidAgent'
```

## Router Configuration (Apache) ##

---

  1. modify your apache site settings
  1. configure httpd, add these lines to your /etc/httpd/conf.d/ssl.conf config (line 74 or so)
```
<VirtualHost _default_:443>
+     PerlRequire /opt/cif/bin/http_api.pl
-     PerlRequire /opt/cif/bin/webapi.pl
       Include /etc/httpd/conf.d/cif.conf
....
```
  1. modify your config at /etc/httpd/conf.d/cif.conf, which should look like:
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

+   SetHandler perl-script
+   PerlResponseHandler CIF::Router::HTTP
+   PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>
```
  1. restart httpd

Continue with the [upgrade](Upgrade_v1#Upgrade.md)