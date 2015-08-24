# Introduction #
This assumes you're using macports (could be adapted for homebrew)

**Table of Contents**


# Details #
## Caveats ##

---

### Mac Ports ###
  1. make sure macports (or homebrew) is up to date
### Xcode ###
  1. install latest version of xcode from the app store
  1. make sure the command line tools are installed (via preferences, ... downloads, ... components)
  1. make sure the command line tools know about it
```
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/
```
  1. re-install perl5 if you're using mac ports (or homebrew) so they know where the new compiler is
## Dependencies ##

---

  1. install some of the base deps
```
$ sudo port install perl5 p5-digest-sha p5-digest-sha1 p5-log-dispatch p5-list-moreutils p5-datetime
```
  1. the perl OSSP::uuid bindings must be installed from source into /opt/local (for macports)
```
$ wget http://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/uuid/uuid-1.6.2.tar.gz
$ tar -zxvf uuid-1.6.2.tar.gz
$ cd uuid-1.6.2
```
  1. read [this thread](https://groups.google.com/forum/#!topic/ci-framework/fSwQSJlpYOk), you'll need to fix some of the headers before you compile
  1. continue on with the compile
```
$ ./configure --prefix=/opt/local --with-perl --with-perl-compat
$ make
$ sudo make install
```
  1. test to make sure uuid is installed properly
```
$ perl -e 'use OSSP::uuid'
```

  1. install the CPAN modules
```
$ sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::SSLeay, Compress::Snappy, Net::Patricia, Iodef::Pb::Simple, DateTime::Format::DateParse, Config::Simple, Log::Dispatch'
```
  1. update config-simple-perl manually (something's wrong where 4.59 won't update on OS X)
```
$ wget http://search.cpan.org/CPAN/authors/id/S/SH/SHERZODR/Config-Simple-4.59.tar.gz
$ tar -zxvf Config-Simple-4.59.tar.gz
$ cd Config-Simple-4.59 && perl Makefile.PL && make && sudo make install
```
## Environment ##

---

  1. set up your user's environment (typically ~/.profile)
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. reload your environment (could require a relog of the terminal app)
```
$ source ~/.profile
```

Continue with the libcif [installation](ClientInstall_v1#Package.md)
# References #

---

  1. http://www.bynkii.com/archives/2012/07/this_package_requires_a_c_comp.html
  1. http://www.stormacq.com/using-macports-with-xcode-4-3-x/