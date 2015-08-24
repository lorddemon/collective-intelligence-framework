# Introduction #
This assumes a clean install of Debian Squeeze (v6.0.x) with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Dependencies ##

---

  1. follow the [libcif-dbi](DbiInstall_v1.md) install instructions
  1. Install the following dependencies
```
$ sudo aptitude -y install apache2 apache2-threaded-dev libapache2-mod-perl2 libapache2-request-perl libapache2-mod-gnutls libapreq2-dev libapr1-dbg
```
  1. Continue with the cif-router [installation](RouterInstall_v1#Install_Package.md)