# Dependency installation when adding 3rd party repositories #

### Add repositories ###
  1. add the EPEL repo
```
$ wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
$ sudo rpm -iv epel-release-5-4.noarch.rpm
$ sudo rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5
```
  1. add the postgresql repo (to install PostgreSQL 8.4)
```
$ wget http://yum.postgresql.org/8.4/redhat/rhel-5.0-x86_64/pgdg-centos-8.4-3.noarch.rpm
$ sudo rpm -iv pgdg-centos-8.4-3.noarch.rpm
```

### Dependency installation ###
  1. install base server dependencies first
```
$ sudo yum -y install rng-utils bind-utils postgresql-server httpd httpd-devel mod_ssl gcc make expat expat-devel uuid uuid-devel wget bind rsync mod_perl mod_perl-devel ntp
```
  1. make sure your clock is up to date (some packages might not install if it's too far skewed)
```
$ sudo /sbin/ntpdate -u pool.ntp.org
```
  1. install some 3rd party dependencies (specifically out of the EPEL repo)
```
$ sudo yum -y install libapreq2 libapreq2-devel perl-libapreq2 zeromq zeromq-devel
```
  1. install the baseline perl modules
```
$ sudo yum -y install perl-Module-Load-Conditional perl-IO-Compress-Base perl-Digest-SHA libxml2 libxml2-devel perl-XML-LibXML uuid-perl perl-DBD-Pg perl-XML-RSS perl-JSON perl-Unicode-String perl-Config-Simple perl-Module-Pluggable perl-MIME-Lite perl-Class-Accessor perl-YAML perl-XML-Parser perl-Net-DNS perl-DateTime-Format-DateParse perl-IO-Socket-INET6 openssl-devel perl-Module-Install perl-Net-SSLeay perl-Class-Trigger perl-IO-Socket-SSL
```

## Continue with installation ##

---

  1. Continue with [CPAN installation](ServerInstall_CentOS5_v1#CPAN.md)