# Introduction #

This doc assumes the CentOS-6.4-x86\_64-minimal.iso was used during installation.

**Table of Contents**


# Details #
## Caveats ##
### Static Address ###
Make sure your instance has a static v4 address
### IPv6 ###
There are some weird issues with the way RHEL (and therefor CentOS) handle the ipv6 driver module, and how some perl modules react to this. If you've left the ipv6 defaults (or leverage ipv6 for routing) you'll probably be OK. If you've "disabled" ipv6, you might run into some build testing issues. If you do, try to force install the modules, gather the testing output (and your ipv6 configurations, etc) and log a bug report. See [here](http://wiki.centos.org/FAQ/CentOS6#head-d47139912868bcb9d754441ecb6a8a10d41781df) for more information on disabling.
### SELINUX ###
Selinux either needs to be disabled or a [policy](http://wiki.centos.org/HowTos/SELinux) needs to be written allowing postgres r/w access to /mnt/archive and /mnt/index
  1. disable selinux via /etc/selinux/config
```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
```
  1. restart the server for the kernel changes to take effect
  1. some helpful discussion references can be found [here](https://groups.google.com/forum/#!tags/ci-framework/selinux)
### EPEL Repo ###
The following dependency installation assumes the RHEL [EPEL](http://fedoraproject.org/wiki/EPEL) repo is not enabled. If you would like to enable it and leverage that there are 3rd party [instructions](http://www.thegeekstuff.com/2012/06/enable-epel-repository) for doing so. Most (if not all) the 'wget' deps should install via the repo using 'yum', but we have done no testing to verify this. Feedback welcome.

If EPEL is NOT enabled, please note that an extra dep is required for Encode::Locale:

https://github.com/collectiveintel/cif-v1/issues/66

## Dependencies Installation ##

---

  1. make sure your base OS is up-to-date (as root) first
```
# yum upgrade
```
  1. install base server dependencies (as root)
```
# yum -y install sudo bind-utils rng-tools postgresql-server httpd httpd-devel mod_ssl gcc make expat expat-devel uuid uuid-devel wget bind rsync libuuid-devel mod_perl mod_perl-devel ntpdate
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
```
  1. or as a one-liner:
```
$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-2.13-1.el6.x86_64.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-devel-2.13-1.el6.x86_64.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/perl-libapreq2-2.13-1.el6.x86_64.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-2.2.0-4.el6.x86_64.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-devel-2.2.0-4.el6.x86_64.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/openpgm-5.1.118-3.el6.x86_64.rpm
```
  1. install the rpm's
```
$ sudo rpm -iv openpgm-5.1.118-3.el6.x86_64.rpm
$ sudo rpm -iv libapreq2-2.13-1.el6.x86_64.rpm libapreq2-devel-2.13-1.el6.x86_64.rpm perl-libapreq2-2.13-1.el6.x86_64.rpm zeromq-2.2.0-4.el6.x86_64.rpm zeromq-devel-2.2.0-4.el6.x86_64.rpm
```
  1. install the baseline perl modules
```
$ sudo yum -y install perl-Digest-SHA libxml2 libxml2-devel perl-XML-LibXML perl-DBD-Pg perl-XML-RSS perl-JSON perl-Unicode-String perl-Config-Simple perl-Module-Pluggable perl-MIME-Lite perl-CPAN perl-Class-Accessor perl-YAML perl-XML-Parser uuid-perl perl-Net-DNS perl-DateTime-Format-DateParse perl-IO-Socket-INET6 openssl-devel perl-Module-Install perl-Net-SSLeay perl-Class-Trigger perl-Date-Manip perl-IO-Socket-SSL
```
  1. install the Test::More module
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Test::More'
```
  1. need to manually install a version of the 'version' module, as most recent update breaks on CentOS6
```
$ wget http://search.cpan.org/CPAN/authors/id/J/JP/JPEACOCK/version-0.9902.tar.gz
$ tar -zxvf version-0.9902.tar.gz
$ cd version-0.9902
$ perl Makefile.PL && make && sudo make install
```
  1. install cpanminus
  1. upgrade cpanm to work with github
```
$ sudo cpanm --self-upgrade
```
  1. work-around for the Linux::Cpuinfo dep
```
$ sudo cpanm git://github.com/gitpan/Linux-Cpuinfo.git@1.7 --force
```
  1. install the remaining CPAN modules
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Module::Build,Test::SharedFork,Test::TCP,Net::Abuse::Utils,Linux::Cpuinfo,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Net::Abuse::Utils::Spamhaus,Net::DNS::Match,Snort::Rule,Parse::Range,Sys::MemInfo,JSON::XS,File::Type,LWP::UserAgent,Class::Trigger,Class::DBI,Net::Patricia,Text::Table,Mozilla::CA,IO::Socket::SSL,IO::Socket::INET6,LWP::Protocol::https,Text::CSV,XML::RSS,LWPx::ParanoidAgent,Log::Dispatch,ZeroMQ'
```

## System Setup ##

---


### Bind Config ###
On RHEL6 with this setup you might get [messages like the following](http://crashmag.net/disable-ipv6-lookups-with-bind-on-rhel-or-centos) if you're not using ipv6:
```
error (network unreachable) resolving '0.158.225.189.zen.spamhaus.org/A/IN': 2001:7fd::1#53: 1 Time(s) 
error (network unreachable) resolving '0.215.141.74.zen.spamhaus.org/A/IN': 2001:7fd::1#53: 1 Time(s) 
error (network unreachable) resolving '0.239.22.98.zen.spamhaus.org/A/IN': 2001:500:3::42#53: 1 Time(s) 
error (network unreachable) resolving '0.239.22.98.zen.spamhaus.org/A/IN': 2001:503:ba3e::2:30#53: 1 Time(s)
```
  1. modify /etc/sysconfig/named:
```
$ echo OPTIONS="-4" | sudo tee -a /etc/sysconfig/named
```
  1. restart bind
### Resolve Config ###
We need to point our dns resoultion to the local nameserver instance.
  1. modify /etc/sysconfig/network-scripts/ifcfg-eth0 with the following DNS1="127.0.0.1" line
```
echo "DNS1=127.0.0.1" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth0
```
  1. restart networking
```
$ sudo ifdown eth0 && sudo ifup eth0
```
  1. Verify resolveconf
```
cat /etc/resolv.conf
```
> Should look similar to:
```
# Generated by NetworkManager
nameserver 127.0.0.1
...
```

### Postgres ###
  1. init the main cluster
```
$ sudo service postgresql initdb
```
  1. The default installation of Postgres is a little out of sync with the rest of the doc, we need to do some symlinking
```
$ sudo mkdir -p /etc/postgresql/8.4/main
$ sudo chown -R postgres:postgres /etc/postgresql
$ sudo chmod 760 -R /etc/postgresql
$ sudo ln -sf /var/lib/pgsql/data/postgresql.conf /etc/postgresql/8.4/main/postgresql.conf
$ sudo ln -sf /var/lib/pgsql/data/pg_hba.conf /etc/postgresql/8.4/main/pg_hba.conf
```
  1. start up the cluster
```
$ sudo service postgresql start
```
### Default CIF user ###

---

  1. create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo useradd cif
```
  1. change the default home permissions
```
$ sudo chmod 770 /home/cif
```

### CIF Router Configuration (Apache) ###

---

Some of the "CIF" values will be created later in the doc, for now just follow the config as is, don't worry about creating things like "/home/cif" etc.
  1. if you need help generating your own certificates, follow the directions [here](http://wiki.centos.org/HowTos/Https)
  1. unless you know what you're doing with virtual hosts, comment out the port-80 stuff in /etc/httpd/conf/httpd.conf (line 130 or so)
```
# Listen: Allows you to bind Apache to specific IP addresses and/or
# ports, in addition to the default. See also the <VirtualHost>
# directive.
#
# Change this to Listen on specific IP addresses as shown below to
# prevent Apache from glomming onto all bound IP addresses (0.0.0.0)
#
#Listen 12.34.56.78:80
+ #Listen 80
```
  1. configure httpd, add these lines to your /etc/httpd/conf.d/ssl.conf config (line 74 or so)
```
<VirtualHost _default_:443>
+      PerlRequire /opt/cif/bin/http_api.pl
+      Include /etc/httpd/conf.d/cif.conf
....
```
  1. create your config at /etc/httpd/conf.d/cif.conf, which should look like:
```
<Location /api>
    SetHandler perl-script
    PerlResponseHandler CIF::Router::HTTP
    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>

```
  1. add your "apache" user to the group "cif" (this modifies /etc/group):
```
$ sudo usermod -a -G cif apache
```
  1. we'll restart apache later in the doc after we install the core CIF code
### Random Number Generator ###

---

The "rngd' service [helps](https://www.centos.org/modules/newbb/viewtopic.php?topic_id=36209) with random number generation (mainly used for generating security certificates in bind and apache, speeds up the entropy process).
  1. modify /etc/sysconfig/rngd to use /dev/urandom as the seed
```
# Add extra options here
EXTRAOPTIONS="-r /dev/urandom"
```
  1. restart rngd
```
$ sudo service rngd restart
```
### Finishing Up ###

---

  1. enable services at startup
```
$ sudo chkconfig --levels 345 postgresql on
$ sudo chkconfig --levels 345 named on
$ sudo chkconfig --levels 345 rngd on
$ sudo chkconfig --levels 345 httpd on
```
### Continue with installation ###

---

1. Continue with [Nameserver configuration](ServerInstall_v1#Bind.md)