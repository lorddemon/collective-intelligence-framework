**Before you Begin**

**Table of Contents**


# Preamble #

---

A semi-complete [ChangeLog](https://github.com/collectiveintel/cif-v1/blob/master/ChangeLog) of v1

A list of known [issues](https://github.com/collectiveintel/cif-v1/issues) for v1

## Backwards Compatibility ##
  * as of v1, the 'CIF-Client' is now part of the client side library 'libcif'
  * the deprecated "CIF::Client" (via CPAN) cannot be used with a v1 instance
  * the v0 client **MUST** be [removed](ClientRemoval_v0.md) first if it's installed

## Caveats ##
  * libcif cannot be installed via CPAN at this time
  * libcif provides:
    * CIF::Client library to build (perl) applications against
    * the 'cif' command
    * by default, is installed to '/opt/cif', can be changed with the '--prefix' flag when running './configure'
  * to build applications in other languages, simply pipe the 'cif' command with '-p json' which will pipe stripped down (non-iodef) json key-pairs to your application
  * currently, libcif defaults to the /opt/cif environment due to it's perl nature
  * future versions of libcif will be written in a lower level language (more portable) and provide high level language bindings
  * a sample python client can be found [here](https://github.com/collectiveintel/cif-client-python/tree/v1)

# Installation #
## Required Dependencies ##
  * (testing) [Debian Squeeze](ClientInstall_DebianSqueeze_v1.md)
  * (testing) [Ubuntu 12](ClientInstall_Ubuntu12_v1.md)
  * (testing) [CentOS 6](ClientInstall_CentOS6_v1.md)
  * (testing) [OSX 7](ClientInstall_OSX7_v1.md)
## Package ##
  1. download the latest [package](https://code.google.com/p/collective-intelligence-framework/downloads/list?can=2&q=label%3ARC3+label%3Av1+summary%3Alibcif-v1)
```
$ tar -xzvf libcif-v1-RC3.tar.gz
$ cd libcif-v1-RC3
$ ./configure && make testdeps
$ sudo make install
```
## Configuration ##
## Environment ##
  1. create a default configuration file
```
$ vi ~/.cif
```
  1. add the following as a template
```
# the simple stuff
[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0
```