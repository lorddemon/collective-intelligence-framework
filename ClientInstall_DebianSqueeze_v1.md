# Introduction #
This assumes a clean install of Debian Squeeze (v6.x) with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Dependencies ##

---

  1. Install the base deps
```
$ sudo aptitude -y install build-essential libdigest-sha1-perl libnet-cidr-perl libossp-uuid-perl libmodule-install-perl libregexp-common-perl libunicode-string-perl libconfig-simple-perl  libhtml-table-perl libtry-tiny-perl libclass-accessor-perl pkg-config libnet-ssleay-perl vim libjson-xs-perl libextutils-parsexs-perl libdatetime-format-dateparse-perl libnet-patricia-perl libdatetime-perl libtext-table-perl libssl-dev
```
  1. Install the remaining CPAN modules
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Module::Build,Test::SharedFork,Test::TCP,Regexp::Common::net::CIDR,LWP::Protocol::https,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Snort::Rule,Log::Dispatch,Net::SSLeay'
```
## Default CIF user ##

---

  1. Create your "cif" user/group (the configure script will default to this user "cif") that will own the application (/opt/cif).
```
$ sudo adduser --disabled-password --gecos '' cif
```
## Environment ##

---

  1. set up your user's environment (typically ~/.profile)
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. reload your environment
```
$ source ~/.profile
```
  1. Continue with the libcif [installation](ClientInstall_v1#Package.md)