<font color='red'>
<h1>Unstable</h1>
</font>

# Introduction #

**Table of Contents**


# Details #
## Install Required Dependencies ##

---

  * (unstable) [Debian Squeeze](SmrtInstall_DebianSqueeze_v1.md)
  * (unstable) [Ubuntu12](SmrtInstall_Ubuntu12_v1.md)
  * (unstable) [CentOS6](SmrtInstall_CentOS6_v1.md)

## Install Package ##
  1. download the latest smrt [package](http://code.google.com/p/collective-intelligence-framework/downloads/list?q=label:v1+smrt)
```
$ tar -xzvf cif-smrt-v1-XXX.tar.gz
$ cd cif-smrt-v1-XXX
$ ./configure && make testdeps
$ sudo make install
```

## Configuration ##
  1. using the cif\_apikeys tool, on the instance where libcif-dbi was installed, generate an apikey for this cif-smrt instance
```
$ cif_apikeys -u cif_smrt -G everyone -g everyone -a -w
userid   key                                  description guid                                 default_guid restricted access write revoked expires created                      
cif_smrt bf1e0a9f-9518-409d-8e67-bfcc36dc5f44             8c864306-d21a-37b1-8705-746a786719bf true         0                 1                     2012-08-15 17:37:18.53348+00 
```
  1. log into the 'cif' user account
```
$ sudo su - cif
```
  1. create a default configuration file on the local smrt instance
```
$ vi ~/.cif
```
  1. add the following as a template, using the apikey generated in the step above
```
[cif_smrt]
# change example.com to your local domain and hostname respectively
# this identifies the data in your instance and ties it to your specific instance in the event
# that you start sharing with others
#name = example.com
#instance = cif.example.com
name = localhost
instance = cif.localhost

# the apikey for cif_smrt
apikey = XXXXXX-XXX-XXXX 
```