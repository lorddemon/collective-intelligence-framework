<font color='red'>
<h1>Unstable</h1>
</font>

# Introduction #

**Table of Contents**


# Details #
## Install Required Dependencies ##
  * (unstable) [Debian Squeeze](RouterInstall_DebianSqueeze_v1.md)
  * (unstable) [Ubuntu 12](RouterInstall_Ubuntu12_v1.md)
  * (unstable) [CentOS 6](RouterInstall_CentOS6_v1.md)
## Install Package ##
  1. download the latest [package](http://code.google.com/p/collective-intelligence-framework/downloads/list?q=label:v1+cif-router)
```
$ tar -xzvf cif-router-v1-XXX.tar.gz
$ cd cif-router-v1-XXX
$ ./configure && make testdeps
$ sudo make install
```
## Configuration ##
  1. create a default configuration file
```
$ vi ~/.cif
```
  1. add the following as a template
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

# logging
#values 0-4
[router]
# set to 0 if it's too noisy and reload the cif-router (apache), only on for RC2
debug = 1
```