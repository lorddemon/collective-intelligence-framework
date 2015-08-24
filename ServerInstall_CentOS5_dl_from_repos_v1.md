# Dependency installation without adding 3rd party repositories #

### Install keys for EPEL and PostgreSQL repos ###
  1. Get Fedoraproject key and add it
```
$ sudo rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5
```
  1. Get Postgresql repo key and add it
```
$ wget http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/pgdg-centos-8.4-3.noarch.rpm
$ rpm2cpio pgdg-centos-8.4-3.noarch.rpm | cpio -idmv
$ sudo rpm --import ~/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
```
  1. Delete the no longer needed files
```
$ rm -rf etc/
$ rm -f pgdg-centos-8.4-3.noarch.rpm
```

### Dependency Installation ###
  1. Install dependencies from default repositories
```
$ sudo yum -y install rng-utils bind-utils httpd httpd-devel mod_ssl gcc make expat expat-devel wget bind rsync mod_perl mod_perl-devel ntp libxml2 libxml2-devel perl-XML-LibXML perl-DBD-Pg perl-XML-Parser perl-Net-DNS perl-IO-Socket-INET6 openssl-devel perl-Net-SSLeay perl-IO-Socket-SSL
```
  1. make sure your clock is up to date (some packages might not install if it's too far skewed)
```
$ sudo /sbin/ntpdate -u pool.ntp.org
```
  1. Download dependencies from 3rd party repositories
    1. make a new directory 'rpms' and cd into it
    1. download the following (note: an easy way to download everything below is to copy and paste the links into a text file, then use `wget -i file`):
```
http://dl.fedoraproject.org/pub/epel/5/x86_64/uuid-1.5.1-3.el5.i386.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/uuid-devel-1.5.1-3.el5.i386.rpm		
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/postgresql-8.4.16-1PGDG.rhel5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/uuid-1.5.1-4.rhel5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/uuid-devel-1.5.1-4.rhel5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/compat-postgresql-libs-4-1PGDG.rhel5.i686.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/compat-postgresql-libs-4-1PGDG.rhel5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/postgresql-server-8.4.16-1PGDG.rhel5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/postgresql-libs-8.4.16-1PGDG.rhel5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/libapreq2-2.09-0.rc2.1.el5.i386.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/libapreq2-2.09-0.rc2.1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/libapreq2-devel-2.09-0.rc2.1.el5.i386.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/libapreq2-devel-2.09-0.rc2.1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-libapreq2-2.09-0.rc2.1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/zeromq-2.1.9-1.el5.i386.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/zeromq-2.1.9-1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/zeromq-devel-2.1.9-1.el5.i386.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/zeromq-devel-2.1.9-1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Digest-SHA-5.47-1.el5.x86_64.rpm
http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/uuid-perl-1.5.1-4.rhel5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-XML-RSS-1.31-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-JSON-2.17-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Unicode-String-2.09-7.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Config-Simple-4.59-7.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-Pluggable-3.60-3.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-MIME-Lite-3.01-5.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Class-Accessor-0.31-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-YAML-0.66-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-DateTime-Format-DateParse-0.04-6.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-Install-0.67-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Class-Trigger-0.12-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Class-Singleton-1.03-3.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-DateTime-0.41-1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-DateTime-Format-Mail-0.30-4.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-DateTime-Format-W3CDTF-0.04-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-ExtUtils-CBuilder-0.18-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-ExtUtils-ParseXS-2.2206-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-IO-stringy-2.110-5.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-Build-0.2807-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-CoreList-2.11-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-ScanDeps-0.75-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-PAR-Dist-0.25-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Params-Validate-0.88-3.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-YAML-Tiny-1.04-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-version-0.7203-1.el5.x86_64.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-Load-0.12-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Locale-Maketext-Simple-0.18-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Module-Load-Conditional-0.18-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Params-Check-0.26-2.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-Locale-Maketext-Lexicon-0.62-1.el5.noarch.rpm
http://dl.fedoraproject.org/pub/epel/5/x86_64/perl-IO-Compress-Base-2.005-2.el5.noarch.rpm
```
  1. install the downloaded packages
```
$ sudo yum -y localinstall *.rpm
```

## Continue with installation ##

---

  1. Continue with [CPAN installation](ServerInstall_CentOS5_v1#CPAN.md)