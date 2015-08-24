<font color='red'>
<h1>Unstable</h1>
</font>

# Introduction #

**Table of Contents**


# Details #
## Install Required Dependencies ##
  * (unstable) [Debian Squeeze](DbiInstall_DebianSqueeze_v1.md)
  * (unstable) [Ubuntu12](DbiInstall_Ubuntu12_v1.md)
  * (unstable) [CentOS6](DbiInstall_CentOS6_v1.md)

## Install Library ##
  1. download the latest libcif-dbi [package](http://code.google.com/p/collective-intelligence-framework/downloads/list?q=label:v1+libcifdbi)
```
$ tar -xzvf libcif-v1-XXX.tar.gz
$ cd libcif-dbi-v1-XXX
$ ./configure && make testdeps
$ sudo make install
```
## Examples ##

---

### Configs ###
the application user must have a a cif config it can read, for example if it's a web application, a /etc/apache/mycif.conf could be created with the following:
```
# cif_archive configuration is required by cif-router, cif_feed (cif-router, libcif-dbi)
[cif_archive]
# if we want to enable rir/asn/cc, etc... they take up more space in our repo
# datatypes = infrastructure,domain,url,email,search,malware,cc,asn,rir
datatypes = infrastructure,domain,url,email,search,malware

# if you're going to enable feeds
# feeds = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
#groups = everyone,group1.example.com,group2.example.com,group3.example.com

# if the normal IODEF restriction classes don't fit your needs
# ref: https://code.google.com/p/collective-intelligence-framework/wiki/RestrictionMapping_v1
# restriction map is required by cif-router, cif_feed (cif-router, libcif-dbi)
[restriction_map]
#white = public 
#green = public 
#amber = need-to-know 
#red   = private

[db]
host = 127.0.0.1
user = postgres
password =
database = cif
```
### Paths ###
In order for an application to leverage the CIF libraries, the '/opt/cif/lib' path must be added to the application.
```
#!/usr/bin/perl

use strict;

# fix lib paths
BEGIN {
        unshift @INC, "/opt/cif/lib";
}

my ($err,$ret) = CIF::Profile->new({
    config  => '/etc/apache/mycif.conf',
});
die($err) if($err);
my $profile = $ret;
...
```