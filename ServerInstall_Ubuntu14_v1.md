# Introduction #
This assumes a clean install of Ubuntu 14 LTS with all base system updates applied. There are some duplicates between the system wide deps and CPAN, this can be ignored. In some cases we need an upgraded version of the module and by installing the system-wide dependency first, it installs some of the other deps via that mechanism too, simplifying the install. Sometimes it's easier to get bugs fixes into CPAN faster than the more stable Debian/Ubuntu tree.

## Notes ##
**http://www.justgohome.co.uk/blog/2014/04/new-in-14-04-apache.html**

**Table of Contents**


# Details #
## Caveats ##
### Static Address ###
Make sure your instance has a static v4 address
### ZeroMQ 2.x ###
There are two different tree's in the zeromq family, 2.x and 3.x, CIF v1 leverages the 2.x family right now. Future versions may be built against the CZMQ api and may be built against either code base. The instructions below will take care of the installation.
### Perl 5.14 CPAN ###
Newer versions of Perl / CPAN have made some [changes](http://sipb.mit.edu/doc/cpan/) to their configuration defaults that affect how packages are installed. If you're not familiar with customizing CPAN, you'll need to start out by boot-strapping your own config. This way it'll install dependencies system wide by default instead of to a local home directory. CIF may be adapted to this in the future, but this is a work-around for now.
  1. boot-strap the default CPAN config
```
$ sudo su - root
$ mkdir -p /root/.cpan/CPAN
$ vi /root/.cpan/CPAN/MyConfig.pm
```
  1. copy / paste the following into `MyConfig.pm`
```
$CPAN::Config = {
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[/root/.cpan/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[/bin/bzip2],
  'cache_metadata' => q[1],
  'check_sigs' => q[0],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[/root/.cpan],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[/usr/bin/gpg],
  'gzip' => q[/bin/gzip],
  'halt_on_failure' => q[0],
  'histfile' => q[/root/.cpan/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[0],
  'keep_source_where' => q[/root/.cpan/sources],
  'load_module_verbosity' => q[none],
  'make' => q[/usr/bin/make],
  'make_arg' => q[],
  'make_install_arg' => q[],
  'make_install_make_command' => q[/usr/bin/make],
  'makepl_arg' => q[INSTALLDIRS=site],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[sudo ./Build],
  'mbuildpl_arg' => q[--installdirs site],
  'no_proxy' => q[],
  'pager' => q[/usr/bin/less],
  'patch' => q[/usr/bin/patch],
  'perl5lib_verbosity' => q[none],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[/root/.cpan/prefs],
  'prerequisites_policy' => q[follow],
  'scan_cache' => q[atstart],
  'shell' => q[/bin/bash],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'tar' => q[/bin/tar],
  'tar_verbosity' => q[none],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[/usr/bin/wget],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
```

Note: when you run the first "perl -MCPAN install ..." command, it will auto-configure a list of local CPAN mirrors for you
## Dependencies Installation ##

---

  1. su root
```
$ sudo su - root
```
  1. Install the base dependencies from the Ubuntu repositories (as root), you may need to do a "aptitude update && aptitude safe-upgrade" if you run into a lot of conflicts first
```
$ aptitude -y install perl rng-tools build-essential postgresql apache2 apache2-threaded-dev gcc g++ make libexpat1-dev libapache2-mod-perl2 libclass-dbi-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev rsync libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config vim libjson-xs-perl perl-modules libdigest-sha-perl libsnappy-dev libdatetime-format-dateparse-perl liblwp-protocol-https-perl libtime-hires-perl libnet-patricia-perl libnet-ssleay-perl liblog-dispatch-perl libregexp-common-net-cidr-perl libtext-table-perl libdatetime-perl libencode-perl libmime-base64-perl libhtml-table-perl libzmq-dev libzmq1 libzeromq-perl libssl-dev cpanminus
```
  1. work-around for the Linux::Cpuinfo dep
```
$ sudo cpanm https://github.com/gitpan/Linux-Cpuinfo/archive/gitpan_version/1.7.tar.gz --force
```
  1. Install the remaining perl dependencies from CPAN (as root)
```
$ PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Test::SharedFork,Test::TCP,Net::Abuse::Utils,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Net::Abuse::Utils::Spamhaus,Net::DNS,Net::DNS::Match,Snort::Rule,Parse::Range,Log::Dispatch,Net::SSLeay,ZeroMQ,Sys::MemInfo,LWP::Protocol::https,LWPx::ParanoidAgent'
```

## System Setup ##

---

### Resolver Config ###
Configure the static interface to use 127.0.0.1 as the nameserver. Bind will be configured next.

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
  1. Restart networking
```
$ sudo ifdown eth0 && sudo ifup eth0
```
  1. Verify resolveconf
```
$ cat /etc/resolv.conf
```
> Should look similar to:
```
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 127.0.0.1
```
### Default CIF user ###

---

Create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser --disabled-password --gecos '' cif
```

### CIF Router Configuration (Apache) ###

---

Some of the "CIF" values will be created later in the doc, for now just follow the config as is, don't worry about creating things like "/home/cif" etc.
  1. enable the default-ssl site (debian):
```
$ sudo a2dismod gnutls
$ sudo a2ensite default-ssl
$ sudo a2enmod apreq2
$ sudo a2enmod ssl
```
  1. unless you know what you're doing with virtual hosts, comment out the port-80 stuff in /etc/apache2/ports.conf
```
$ sudo vi /etc/apache2/ports.conf
```
```
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default
# This is also true if you have upgraded from before 2.2.9-3 (i.e. from
# Debian etch). See /usr/share/doc/apache2.2-common/NEWS.Debian.gz and
# README.Debian.gz

+ #NameVirtualHost *:80
+ #Listen 80

<IfModule mod_ssl.c>
    # If you add NameVirtualHost *:443 here, you will also have to change
    # the VirtualHost statement in /etc/apache2/sites-available/default-ssl
    ...
```
  1. configure apache2, add this line to your default-ssl site (or default if you're not using TLS)
```
$ sudo vi /etc/apache2/sites-available/default-ssl
```
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
+      PerlRequire /opt/cif/bin/http_api.pl
+      Include /etc/apache2/cif.conf
....
```
  1. create your config at /etc/apache2/cif.conf, which should look like:
```
$ sudo vi /etc/apache2/cif.conf
```
```
<Location /api>
    SetHandler perl-script
    PerlResponseHandler CIF::Router::HTTP
    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>

```
  1. add your "www-data" user (whoever apache is set to run under) to the group "cif" (/etc/group):
```
$ sudo adduser www-data cif
```
### Random Number Generator ###

---

The "rng-tools' service helps with random number generation (mainly used for generating security certificates in bind and apache, speeds up the entropy process).
  1. modify /etc/default/rng-tools to use /dev/urandom as the seed
```
$ echo 'HRNGDEVICE=/dev/urandom' | sudo tee -a /etc/default/rng-tools
```
  1. restart rng-tools
```
$ sudo service rng-tools restart
```
## Continue ##

---

Continue with [Bind configuration](ServerInstall_v1#Bind.md)