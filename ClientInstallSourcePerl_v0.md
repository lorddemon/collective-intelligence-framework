# Table of Contents #



# Installation #
## Distro Helpers ##
  * [BSD](CliPerlClientBSD_v0.md)
  * [Cygwin](CliPerlClientCygwin_v0.md)

## From Source ##
  1. Make sure you have the following dependancies installed:
    * libssl-dev / openssl-devel (deb / RHEL)
    * make, automake (developer tools on OS X)
    * build-essential (deb)
  1. install the client library
```
$ sudo perl -MCPAN -e 'install CIF::Client'
```
  1. setup your [configuration file](CliGlobalConfigurationFile_v0.md)

# Known Issues #
  * BSD **Performance** p5-JSON-XS will solve some performance issues
  * **TLS** there have been reports of TLS "read" errors on older versions of REHL (5.4, etc), the cause is still unknown.
  * TLS Issues
    * if the server requires a **proxy**, some perl dep's will **fail to install**, most likely LWP::Protocol::https.
    * in some cases where LWP::Protocol::https fails to install you might see "**Can't locate object method "ssl\_opts" via package "LWP::UserAgent"**"... too.
    * The work-around is to install this dep manually to bypass the connectivity tests:
```
$ wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/LWP-Protocol-https-6.02.tar.gz
$ tar -zxvf LWP-Protocol-https-6.02.tar.gz
$ cd LWP-Protocol-https-6.02
$ perl Makefile.PL
$ make
$ sudo make install
```
  * **MacOS X 10.7** -- If you install XCode 4.3, you'll need to go to Preferences, install cmdline tools (you'll also need to reg as a developer). You should use [4.2.1](https://developer.apple.com/downloads/index.action) for now if you don't want to reg as developer.