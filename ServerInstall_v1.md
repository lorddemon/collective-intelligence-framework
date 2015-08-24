**Table of Contents**


# Preamble #

---

If you have not joined the [CIF Community](https://groups.google.com/forum/?fromgroups#!forum/ci-framework) yet, please do. It's a great place to ask questions..

A semi-complete v1 [ChangeLog](https://github.com/collectiveintel/cif-v1/blob/master/ChangeLog)

A list of known v1 [issues](https://github.com/collectiveintel/cif-v1/issues)

The v1 FAQ can be found [here](FAQ_v1.md)

Issues being discussed on the mailing list can be found [here](https://groups.google.com/forum/?hl=en&fromgroups=#!tags/ci-framework/v1)

## v0 Compatibility ##
  * You **cannot** run this beta on the same box as CIF v0, it will break stuff. See the client v0 [removal guide](ClientRemoval_v0.md)
  * older cif clients (v0, v1\_RC1, v1\_RC2) will not work with this current versions of CIF

## v1 Client ##
  * check out the v1 client [installer](ClientInstall_v1.md) to install the libcif client libraries (which provides the 'cif' command) on a separate host
  * this document assumes you're testing an instance where the cif client and the server are on the same hardware.
  * If you try to run CIF v1 while watching [this](http://www.jibjab.com/view/coepggrUTQOmCSW6FZrBSg?mt=1), it might not install correctly.

## Upgrading ##
<font color='red'>If you're upgrading an older instance (v0 or v1-RC2+), follow the <a href='Upgrade_v1.md'>upgrade guide</a></font>

## System Requirements ##
These requirements will handle everything on the same box pretty well with the default open source data-sets. The more (bigger) data-sets you add, the more ram / disk space you'll need. The more cores you add, the more threads that can "batch out" the feed parsers (thus, resulting in faster data consumption).

These specs will handle around 10k feeds at once with minimal impact on memory usage. Past that you'll need to start doubling your specs. Virtual machine technology is great for prototyping your implementation and will give you a good baseline of what you'll need for production.

Keep in mind that not all virtual machine software are created equal. Some more production grade (vmware, etc) might work better than others (vbox, kvm, etc). If you experience exceptional degraded performance with the resources cited below, please provide that [feedback](https://groups.google.com/forum/?fromgroups=#!tags/ci-framework/performance) (with specs, tests run, etc).

Some initial benchmarking [stats](https://docs.google.com/spreadsheet/ccc?key=0AvXpkVE0WKXgdHVOcW9WVnZQSHVnbkg5d1dXX2hyT0E#gid=0) to test a setup against

### Small Install ###

---

  * an x86-64bit platform (vm or bare-metal)
  * at-least 4GB ram
  * at-least 2 cores
  * at-least 100GB of free (after OS install) disk space, which should allow you to retain a years worth of data.

### Large Install ###

---

  * an x86-64bit platform (bare-metal)
  * at-least 16GB ram
  * at-least 16 cores
  * at-least 500GB of free (after OS install) disk space, which should allow you to retain a years worth of data.
  * RAID + LVM knowledge

# Setup #
## Choose an operating system ##

---

Debian/Ubuntu is the operating system in which CIF is developed against and is the most commonly used. A RHEL derivative is the second most common platform used by the community.

In theory any current Unix/Linux operating system should be able to run CIF. The challenge may be installing the required applications and dependencies.

## Disk Layout ##

---

Consult the Disk Layout Guide before setting up your operating system. There are implications as to how this is done based on which type of install is opted for. Larger install's with LVM require a bit more configuration than a small install.

  1. [Disk Layout Guide](DiskLayout_v1.md)

## Required applications and dependencies ##

---

Choose the distribution you used as your base operating system and install the required applications and dependencies.

**We do NOT support non 'LTS' type distro's, eg: release cycles less than 18months, Fedora, non-LTS ubuntu, etc...**

  * (stable) [Ubuntu 12 LTS](ServerInstall_Ubuntu12_v1.md)
  * (unstable) [Ubuntu 14 LTS](ServerInstall_Ubuntu14_v1.md)
  * (stable) [Debian Squeeze (6)](ServerInstall_DebianSqueeze_v1.md)
  * (stable) [Debian Wheezy (7)](ServerInstall_DebianWheezy_v1.md)
  * (stable) [CentOS 6](ServerInstall_CentOS6_v1.md)
  * (testing) [CentOS 5](ServerInstall_CentOS5_v1.md)

## Postgres, Bind and Resolvconf configuration ##

---

### Bind ###
Configure Bind to use Google public DNS servers to push domain name resolution upstream.
  1. [BindSetup](BindSetup_v1.md)

### Postgres ###
Configure Postgres authentication and performance tuning
  1. [PostgresSetup](PostgresInstall_v1.md)

## Installing CIF ##

---

### Overview ###
This guide assumes that the client is on the same hardware as the backend server/router components. If you want to build out in HA mode, se our [HA Guide](CIFInfrastructureDiagram_v1.md).

### Upgrading ###
<font color='red'>Follow the <a href='Upgrade_v1.md'>upgrade guide</a></font>

### New Installation ###
  1. power down apache2
  1. install the latest CIF [package](https://github.com/collectiveintel/cif-v1/releases/) (be sure to pick the green-highlighted pre-built package, not the 'source')
```
$ tar -xzvf cif-v1-1.X.X.tar.gz
$ cd cif-v1-1.X.X
$ ./configure && make testdeps
$ sudo make install
$ sudo make initdb
```

_note: there is no need for 'make' itself, just 'configure' and 'make install' since this is a Perl based application, nothing to compile..._

# Configuration #

---

## Environment ##
  1. log in as the cif user:
```
$ sudo su - cif
```
  1. setup your environment $PATH
    * DEBIAN /home/cif/.profile
    * RHEL /home/cif/.bash\_profile
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. reload your environment by logging out and then back into the cif user
```
$ logout
$ sudo su - cif
```
## Default Config ##
  1. as the cif user create /home/cif/.cif
```
$ vi ~/.cif
```
  1. add the following as a template, the API KEYS will be generated in a following section, for now just use the XXX as the placeholders.
```
# the simple stuff
# cif_archive configuration is required by cif-router, cif_feed (cif-router, libcif-dbi)
[cif_archive]
# if we want to enable rir/asn/cc, etc... they take up more space in our repo
# datatypes = infrastructure,domain,url,email,search,malware,cc,asn,rir
datatypes = infrastructure,domain,url,email,search,malware

# if you're going to enable feeds
# feeds = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
#groups = everyone,group1.example.com,group2.example.com,group3.example.com

# client is required by the client, cif_router, cif_smrt (libcif, cif-router, cif-smrt)
[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0

# cif_smrt is required by cif_smrt
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

# advanced stuff
# db config is required by cif-router, cif_feed, cif_apikeys (cif-router, libcif-dbi)
[db]
host = 127.0.0.1
user = postgres
password =
database = cif

# if the normal IODEF restriction classes don't fit your needs
# ref: https://code.google.com/p/collective-intelligence-framework/wiki/RestrictionMapping_v1
# restriction map is required by cif-router, cif_feed (cif-router, libcif-dbi)

[restriction_map]
#need-to-know = amber
#private = red
#default = amber
#public = green     

# logging
# values 0-4
[router]
# set to 0 if it's too noisy and reload the cif-router (apache), only on for RC2
debug = 1
```

## Enabling Feed Generation ##
To enable feed generation, which requires more space a few more options need to be ticked. If you only plan to leverage the system for "querying" (not putting feeds into something like a firewall, etc) then this section can be skipped.

  1. modify the 'cif' user's ~/.cif config accordingly:
```
$ vi ~/.cif
```
  1. add the following to the cif\_archive section:
```
[cif_archive]
...
feeds = infrastructure,domain,url,email,search,malware
```
  1. add this section to end of the config
```
[cif_feed]
# max size of any feed generated
limit = 50000

# each confidence level to generate
confidence = 95,85,75,65

# what 'role' keys to use to generate the feeds
roles = role_everyone_feed

# how far back in time to generate the feeds from
limit_days = 7

# how many days of generated feeds to keep in the archive
feed_retention = 7
```
  1. generate a "role key" for generating feeds everyone (with an apikey) in the system can query for. They apikey generated can be ignored as it's just a placeholder for the system.
```
$ cif_apikeys -u "role_everyone_feed" -G everyone -g everyone -a
```
  1. log out of the cif user and restart apache

### APIKey ###
  1. make sure you're still logged in as the 'cif' user and have set the proper environment stuff or the following commands will fail
```
$ sudo su - cif
```
  1. generate your initial apikey to be used by your client
```
$ cif_apikeys -u "<myuser@example.com>" -a -g everyone -G everyone
userid              key                                  description guid                                 default_guid access write revoked expires created                      
myuser@mydomain.com 249cd5fd-04e3-46ad-bf0f-c02030cc864a             8c864306-d21a-37b1-8705-746a786719bf true         all                          2012-08-01 11:50:15.969724+00
```
  1. check to make sure your 'guid' has _**8c864306-d21a-37b1-8705-746a786719bf**_ in it. If it doesn't you won't be able to see all the default, public data that's permissioned to the 'everyone' group in your system
  1. generate a cif-smrt key to be used by cif\_smrt to submit data to the router:
```
$ cif_apikeys -u cif_smrt -G everyone -g everyone -a -w
userid   key                                  description guid                                 default_guid restricted access write revoked expires created                      
cif_smrt bf1e0a9f-9518-409d-8e67-bfcc36dc5f44             8c864306-d21a-37b1-8705-746a786719bf true         0                 1                     2012-08-15 17:37:18.53348+00 
```
  1. to list all of your apikeys:
```
$ cif_apikeys -l
```
  1. cif\_apikeys -h will give you an example of how to use the tool
  1. replace the "apikey = XXXX" in your config with the client and cif\_smrt keys respectively
```
$ vi ~/.cif
```
  1. log out of the cif user into your regular user (that has sudo access)
  1. if you're working with groups that aren't defined out of the box ('everyone') check out the [Group Support](GroupSupport_v1.md) doc.

## Router Setup ##
Most of this setup should have been accomplished in the distribution specific doc (Debian, RHEL, etc).
  1. restart apache
  1. re-login as the cif user and test your connectivity to the router:
```
$ sudo su - cif
$ cif -d -q example.com
[DEBUG][2012-12-20T15:18:34Z]: generating query
[DEBUG][2012-12-20T15:18:34Z]: query: example.com
[DEBUG][2012-12-20T15:18:34Z]: sending query
[DEBUG][2012-12-20T15:18:35Z]: decoding...
[DEBUG][2012-12-20T15:18:35Z]: processing: 2 items
[DEBUG][2012-12-20T15:18:35Z]: final results: 2
[DEBUG][2012-12-20T15:18:35Z]: done processing
[DEBUG][2012-12-20T15:18:35Z]: formatting as Table...
WARNING: This table output not to be used for parsing, see "-p plugins" (via cif -h)
WARNING: Turn off this warning by adding: 'table_nowarning = 1' to your ~/.cif config

feed description:   search example.com
feed reporttime:    2012-12-20T15:18:35Z
feed uuid:          fa843602-4f62-49b5-99c0-010d4c873ee3
feed guid:          everyone
feed restriction:   private
feed confidence:    0
feed limit:              50

restriction|guid    |assessment|description       |confidence|detecttime          |reporttime          |address    |alternativeid_restriction|alternativeid
private    |everyone|search    |search example.com|50        |2012-12-20T15:18:35Z|2012-12-20T15:18:35Z|example.com|                         |             
[DEBUG][2012-12-20T15:18:35Z]: done
```

# Initialization #

---

## Load Data ##
  1. you should be logged in as the 'cif' user for this
```
$ sudo su - cif
```
  1. run the cif\_crontool
```
$ time cif_crontool -p hourly -d -P
$ time cif_crontool -p daily -d -P
```

## Testing ##

---

### Query Only ###
If you've setup a query-only system (no feeds), you should be able to run the following to test for data:
```
cif@ubuntu:~$ cif -d -M -q google.com
[DEBUG][2012-12-20T16:15:32Z]: generating query
[DEBUG][2012-12-20T16:15:32Z]: query: google.com
[DEBUG][2012-12-20T16:15:32Z]: sending query
[DEBUG][2012-12-20T16:15:32Z]: decoding...
[DEBUG][2012-12-20T16:15:32Z]: processing: 3 items
[DEBUG][2012-12-20T16:15:32Z]: final results: 3
[DEBUG][2012-12-20T16:15:32Z]: done processing
[DEBUG][2012-12-20T16:15:32Z]: formatting as Table...
WARNING: This table output not to be used for parsing, see "-p plugins" (via cif -h)
WARNING: Turn off this warning by adding: 'table_nowarning = 1' to your ~/.cif config

feed description:   search google.com
feed reporttime:    2012-12-20T16:15:32Z
feed uuid:          e7cd9386-cd14-4232-8998-2d89af47ad40
feed guid:          everyone
feed restriction:   private
feed confidence:    0
feed limit:              50

restriction |guid    |assessment|description      |confidence|detecttime          |reporttime          |address   |alternativeid_restriction|alternativeid                           
need-to-know|everyone|whitelist |alexa #1         |95        |2012-12-20T16:00:00Z|2012-12-20T00:00:00Z|google.com|public                   |http://www.alexa.com/siteinfo/google.com
private     |everyone|search    |search google.com|50        |2012-12-20T15:30:57Z|2012-12-20T15:30:57Z|google.com|                         |                                        

[DEBUG][2012-12-20T16:15:32Z]: done
```
### With Feeds ###
  1. if you've setup a system with feeds enabled, first run the cif\_feed command to generate the first batch of feeds to test with:
```
$ time cif_feed -d
```
  1. next query for one of the feeds:
```
$ time cif -M -d -q infrastructure/scan -c 85
[DEBUG][2012-12-20T16:20:30Z]: generating query
[DEBUG][2012-12-20T16:20:30Z]: query: infrastructure/scan
[DEBUG][2012-12-20T16:20:30Z]: sending query
[DEBUG][2012-12-20T16:20:30Z]: decoding...
[DEBUG][2012-12-20T16:20:30Z]: processing: 475 items
[DEBUG][2012-12-20T16:20:32Z]: final results: 475
[DEBUG][2012-12-20T16:20:32Z]: done processing
[DEBUG][2012-12-20T16:20:32Z]: formatting as Table...
WARNING: This table output not to be used for parsing, see "-p plugins" (via cif -h)
WARNING: Turn off this warning by adding: 'table_nowarning = 1' to your ~/.cif config

feed description:   scan infrastructure feed
feed reporttime:    2012-12-20T16:11:45Z
feed uuid:          7f734f92-6ce5-4f1c-8acf-cca304800873
feed guid:          everyone
feed restriction:   private
feed confidence:    85
feed limit:              0

restriction |guid    |assessment|description|confidence|detecttime          |reporttime          |address        |prefix          |protocol|portlist |asn   |asn_desc                                                                                        |cc|rir    |alternativeid_restriction|alternativeid                                              
need-to-know|everyone|scanner   |ssh        |85        |2012-12-20T16:00:00Z|2012-12-18T00:00:00Z|37.77.82.122   |37.77.80.0/20   |6       |22       | 57757|ENZUINC-EU Enzu Inc                                                                             |NL|RIPENCC|public                   |http://www.openbl.org/lists/date_all.txt                   
need-to-know|everyone|scanner   |ssh        |85        |2012-12-20T16:00:00Z|2012-12-19T00:00:00Z|119.188.7.201  |119.176.0.0/12  |6       |22       |  4837|CHINA169-BACKBONE CNCGROUP China169 Backbone                                                    |CN|APNIC  |public                   |http://danger.rulez.sk/projects/bruteforceblocker/blist.php
need-to-know|everyone|scanner   |ssh        |85        |2012-12-20T16:00:00Z|2012-12-19T00:00:00Z|111.74.82.33   |111.72.0.0/13   |6       |22       |  4134|CHINANET-BACKBONE No.31,Jin-rong Street                                                         |CN|APNIC  |public                   |http://www.openbl.org/lists/date_all.txt                   
need-to-know|everyone|scanner   |ssh        |85        |2012-12-20T16:00:00Z|2012-12-19T00:00:00Z|63.137.144.85  |63.137.0.0/16   |6       |22       |  3561|SAVVIS Savvis                   
...
...
...
```

# Finishing Up #

---


## Configuring Log Rotation ##

These instructions assume your distribution uses [Logrotate](https://fedorahosted.org/logrotate/) to rotate log files.

  1. Create the log folder and set permissions
```
$ sudo mkdir /var/log/cif
$ sudo chown cif:cif /var/log/cif
```
  1. Create the Logrotate conf file
```
$ sudo vi /etc/logrotate.d/cif
```
  1. Copy and paste the following
```
/var/log/cif/*.log {
	  weekly
	  rotate 52
	  compress
	  notifempty
	  missingok
	  nocreate
}
```

## Configuring Crontab ##
  1. log into the cif user and modify it's cron tab
```
$ sudo su - cif
$ crontab -e
```
  1. configure the following
```
# set the path
PATH=/bin:/usr/local/bin:/opt/cif/bin

# pull feed data
05     *       * * * /opt/cif/bin/cif_crontool -p hourly -P -d -A root >> /var/log/cif/crontool_hourly.log 2>&1
30     00      * * * /opt/cif/bin/cif_crontool -p daily -P -d -A root >> /var/log/cif/crontool_daily.log 2>&1

# if you've enabled feed generation in your config
45     *       * * * /opt/cif/bin/cif_feed -d >> /var/log/cif/cif_feed.log 2>&1
```