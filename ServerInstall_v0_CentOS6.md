# Introduction #

CentOS 6 Server Install -- this doc considered unstable, although it should mostly work, it's not kept as up to date as the stable doc

# Details #
  1. install server deps
```
$ sudo yum install rng-tools postgresql-server httpd httpd-devel mod_ssl gcc make expat expat-devel mod_perl mod_perl-devel perl-Digest-SHA perl-Digest-SHA1 libxml2 libxml2-devel perl-XML-LibXML uuid-perl perl-DBD-Pg bind perl-XML-RSS perl-JSON rsync perl-Unicode-String perl-Config-Simple perl-Module-Pluggable perl-MIME-Lite perl-CPAN perl-Class-Accessor perl-YAML perl-XML-Parser uuid uuid-devel uuid-perl perl-Text-Table perl-Net-DNS perl-DateTime-Format-DateParse perl-IO-Socket-INET6 perl-Regexp-Common-net openssl-devel perl-HTTP-Server-Simple wget
```
  1. if you have the epel repo installed:
```
$ sudo yum install libapreq2 libapreq2-devel perl-libapreq2
```
  1. if you don't have that repo (see [this](http://www.centos.org/modules/newbb/viewtopic.php?topic_id=18264) for more info):
```
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-2.13-1.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-devel-2.13-1.el6.x86_64.rpm
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/perl-libapreq2-2.13-1.el6.x86_64.rpm
$ sudo rpm -i libapreq2-2.13-1.el6.x86_64.rpm libapreq2-devel-2.13-1.el6.x86_64.rpm perl-libapreq2-2.13-1.el6.x86_64.rpm
```
  1. install the remaining CPAN modules (follow all the deps)
    1. via perl -MCPAN -e
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Class::DBI, Net::CIDR, Module::Install, Apache2::Request, Regexp::Common, File::Type, Text::CSV, HTML::Table, APR::Table, Net::Abuse::Utils, Apache2::REST, Linux::Cpuinfo, XML::IODEF, LWP::Simple, VT::API,Try::Tiny'
```
    1. or alternatively
```
$ sudo perl -MCPAN -e 'shell'
cpan> o conf prerequisites_policy follow
cpan> install Class::DBI, Net::CIDR, Module::Install, Apache2::Request, Regexp::Common, File::Type, Text::CSV, HTML::Table, APR::Table
```