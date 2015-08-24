# Introduction #
This assumes a clean install of Ubuntu v12.x with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Caveats ##

---


## Dependencies ##

---

  1. follow the [libcif-dbi](ServerInstall_Dbi_CentOS6_v1.md) install instructions
  1. Install the following dependencies
```
$ yum -y install sudo rng-tools httpd httpd-devel mod_ssl mod_perl mod_perl-devel ntpdate
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
$ sudo rpm -iv libapreq2-2.13-1.el6.x86_64.rpm libapreq2-devel-2.13-1.el6.x86_64.rpm perl-libapreq2-2.13-1.el6.x86_64.rpm
```

  1. Continue with the cif-router [installation](RouterInstall_v1#Package.md)