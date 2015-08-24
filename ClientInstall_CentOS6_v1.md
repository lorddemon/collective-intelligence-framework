# Introduction #
This assumes a clean install of RHEL/CentOS6 with sudo and all base system updates applied.

**Table of Contents**


# Details #
## Caveats ##

---

None known
## Dependencies ##

---

  1. install base server dependencies (as root)
```
$ yum -y install sudo gcc make uuid uuid uuid-devel wget libuuid-devel ntpdate
```
  1. make sure your clock is up to date (some packages might not install if it's too far skewed)
```
$ sudo ntpdate -u pool.ntp.org
```
  1. install the baseline perl modules
```
$ sudo yum -y install perl-Digest-SHA uuid-perl perl-JSON perl-Unicode-String perl-Config-Simple perl-Module-Pluggable perl-MIME-Lite perl-CPAN perl-Class-Accessor perl-YAML uuid-perl perl-DateTime-Format-DateParse openssl-devel perl-Module-Install perl-Net-SSLeay
```
  1. install the remaining CPAN modules (PERL\_MM\_USE\_DEFAULT=1 will auto "yes" to the prompts)
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Snort::Rule,Log::Dispatch,JSON::XS,LWP::UserAgent,Net::Patricia,Text::Table,Mozilla::CA,IO::Socket::SSL,IO::Socket::INET6,LWP::Protocol::https'
```
  1. Net-SSLeay > 1.49 has some build issues and perl-Net-SSLeay that comes with CentOS6 is too old, therefore we must install 1.49 manually:
```
$ wget http://search.cpan.org/CPAN/authors/id/M/MI/MIKEM/Net-SSLeay-1.49.tar.gz
$ tar -zxvf Net-SSLeay-1.49.tar.gz
$ cd Net-SSLeay-1.49
$ perl Makefile.PL
$ sudo make install
```
## Environment ##
### Default CIF user ###

---

  1. create your "cif" user/group (the configure script will default to this user "cif") that will own /opt/cif
```
$ sudo adduser cif
```
  1. change the default home permissions
```
$ sudo chmod 770 /home/cif
```

---

  1. set up your user's environment (typically ~/.bash\_profile)
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. reload your environment
```
$ source ~/.bash_profile
```

Continue with the libcif [installation](ClientInstall_v1#Package.md)