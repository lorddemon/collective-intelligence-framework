

# Preamble #
  * CIF is considered a technology demo. Although most working bits are considered stable for production use, there are many known architectural limitations that are being worked out in the next release (see the RoadMap for more detailed information).
    * the code is written in perl (bad threading, slow)
    * the database is embedded in postgres instead of something like hbase
    * the technology was written to be embedded as a single server, instead of an agent / manager / database relationship setup

  * These scripts do a lot of dns queries. You're gonna wanna install bind and configure it to use forwarders. Maybe something like google public dns to help mask your queries. Then point your resolv.conf to localhost

  * Once installed, monitor your dns traffic a bit, your server will be looking up some interesting information. Get a good handle on this and work with your security teams to whitelist this server.

  * This framework was developed against debian (lenny, squeeze and ubuntu > 10.10 or so). This has **NOT** been tested against any other distro's yet (RHEL, BSD, etc). Purely due to lack of cycles. Look here for new doc to pop up when that's complete (or help us write it).

# System Requirements #
These requirements will handle everything on the same box pretty well with the default open source data-sets. The more (bigger) data-sets you add, the more ram / disk space you'll need. The more cores you add, the more threads that can "batch out" the feed parsers (thus, resulting in faster data consumption).

These specs will handle around 10k feeds at once with minimal impact on memory usage. Past that you'll need to start doubling your specs. Virtual machine technology is great for prototyping your implementation and will give you a good baseline of what you'll need for production.

  1. an x86-64bit platform
  1. at-least 8GB ram
  1. at-least 4 cores
  1. at-least 100GB of free (after OS install) disk space, which will last you about 6-9 months.

# Prerequisites #
## Required Services ##
  1. Join the [mailing list](http://groups.google.com/group/ci-framework) -- we like to archive the Q & A there. When you ask questions directly, we will usually Cc our responses.
  1. [DiskLayout](DiskLayout_v0.md)
  1. [PostgresInstall](PostgresInstall_v0.md)
  1. BindSetup

## System Deps ##
### Stable ###
  1. [Debian Lenny](ServerInstall_v0_Lenny.md)
  1. [Debian Squeeze](ServerInstall_v0_Squeeze.md)
  1. [(X|K|U)buntu v10](ServerInstall_v0_Ubuntu10.md)
### Unstable ###
  1. [(X|K|U)buntu v12.04](ServerInstall_v0_Ubuntu12.md)
  1. [From Source](ServerInstall_v0_Generic.md)
  1. [CentOS 6](ServerInstall_v0_CentOS6.md)

# Install #
## Known Issues ##
  1. If you've modified anything other than /opt/cif/etc/custom.cfg in /opt/cif/etc, **BACK UP YOUR etc/cif** directory. This install will overwrite all the main .cfg files
  1. **IF YOU'RE USING A PREVIOUS VERSION OF CIF**, you'll need to drop your database, including any apikeys you've generated. Make sure you [back up your apikeys table](ServerBackup_v0.md) using pg\_dump, you can then re-import the apikeys once the new database has been setup.
  1. we're using postgres as an embedded db, these current configs assume your postgres instance is locked down from the outside world. This will be changed in future releases.

## Server ##
  1. create the index / archive table spaces if you haven't via [DiskLayout](DiskLayout_v0.md) already (it's OK if you don't want to use LVM, these directories can exist on your root volume if you choose, but performance will increase if these are spread out across many disks):
```
$ sudo mkdir /mnt/archive
$ sudo mkdir /mnt/index
$ sudo chown postgres:postgres /mnt/index
$ sudo chown postgres:postgres /mnt/archive
$ sudo chmod 770 /mnt/index
$ sudo chmod 770 /mnt/archive
```
  1. install the PerlClient (we use some functions in it for the server)
  1. create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser --disabled-password --gecos '' cif
```
  1. if you're upgrading, make sure you've backed up /opt/cif/etc appropriately (if you've modified anything inside it)
  1. v0.03 **requires** the CPAN module 'Try::Tiny', if you haven't otherwise installed it:
```
$ sudo perl -MCPAN -e 'install Try::Tiny'
```
  1. install the [latest](http://code.google.com/p/collective-intelligence-framework/downloads/list?q=label:v0) core instance
```
$ tar -zxvf cif-v0.XX.tar.gz
$ cd cif-0.XX
$ ./configure
$ make testdeps
$ make fixdeps
$ sudo make install
```
  1. if this is a first-time install:
```
$ sudo make initdb
$ make tables
```
  1. these types of messages are considered normal:
```
NOTICE:  table "domain" does not exist, skipping
```
  1. if you're upgrading a previous install you'll need to restart apache2
```
$ sudo /etc/init.d/apache2 restart
```
## Configuration ##
### Apache2 ###
  1. enable the default-ssl site (debian):
```
$ sudo a2ensite default-ssl
$ sudo a2enmod apreq
$ sudo a2enmod ssl
```
  1. unless you know what you're doing with virtual hosts, comment out the port-80 stuff in /etc/apache2/ports.conf
```
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default
# This is also true if you have upgraded from before 2.2.9-3 (i.e. from
# Debian etch). See /usr/share/doc/apache2.2-common/NEWS.Debian.gz and
# README.Debian.gz

+ #NameVirtualHost *:80
+ #Listen 80

<IfModule mod_ssl.c>
    # If you add NameVirtualHost *:443 here, you will also have to change
    # the VirtualHost statement in /etc/apache2/sites-available/default-ssl
    ...
```
  1. configure apache2, add this line to your default-ssl site (or default if you're not using TLS)
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
+      PerlRequire /opt/cif/bin/webapi.pl
+      Include /etc/apache2/cif.conf
....
```
  1. create your config at /etc/apache2/cif.conf, which should look like:
```
<Location /api>
    SetHandler perl-script
    PerlSetVar Apache2RESTHandlerRootClass "CIF::WebAPI::Plugin"
    PerlSetVar Apache2RESTAPIBase "/api"
    PerlResponseHandler Apache2::REST
    PerlSetVar Apache2RESTWriterDefault 'json'
    PerlSetVar Apache2RESTAppAuth 'CIF::WebAPI::AppAuth'

    # feed defaults
    PerlSetVar CIFLookupLimitDefault 500
    PerlSetVar CIFDefaultFeedSeverity "high"

    # extra outputs
    PerlAddVar Apache2RESTWriterRegistry 'table'
    PerlAddVar Apache2RESTWriterRegistry 'CIF::WebAPI::Writer::table'
</Location>

```
  1. add your "www-data" user (whoever apache is set to run under) to the group "cif" (/etc/group):
```
$ sudo adduser www-data cif
```
  1. restart apache2
### CIF Config ###
  1. log in as the cif user:
```
$ sudo su - cif
```
  1. modify your local path, vi ~/.profile
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. make a directory for your backups, where possible make this an NFS mount or SSHFS mount to another server
```
$ mkdir backups
```
  1. generate your initial apikey to be used with your [client](ClientSetup.md)
```
$ cif_apikeys -u myuser@mydomain.com -a -g everyone -G everyone
userid              key                                  description guid                                 default_guid access write revoked created                     
myuser@mydomain.com 4c3b44b2-8196-4af9-a77c-afb182793544             8c864306-d21a-37b1-8705-746a786719bf true         all                  2011-10-25 11:40:58.81532+00
```
  1. check to make sure your 'guid' has _**8c864306-d21a-37b1-8705-746a786719bf**_ in it. If it doesn't you won't be able to see all the default, public data that's permissioned to the 'everyone' group in your system
  1. to list all of your apikeys:
```
$ cif_apikeys -l
```
  1. cif\_apikeys -h will give you an example of how to use the tool
  1. configure your ~/.cif for generating feeds
```
[cif_feeds]
maxrecords = 10000
severity_feeds = high,medium
confidence_feeds = 95,85
apikeys = role_everyone_feed
max_days = 2
disabled_feeds = hash,rir,asn,countrycode,malware
```
  1. DO NOT CHANGE 'disabled\_feeds' unless you know what you're doing, you **will** get errors.
  1. add this to /opt/cif/whitelist\_infrastructure, make sure the file has the cif:cif permissions:
```
0.0.0.0/8
10.0.0.0/8
127.0.0.0/8
192.168.0.0/16
169.254.0.0/16
192.0.2.0/24
224.0.0.0/4
240.0.0.0/5
248.0.0.0/5
```
  1. setup a role-key for your default feeds:
```
 $ cif_apikeys -u role_everyone_feed -a -g everyone -G everyone
```
## Load Data ##
  1. log in as the cif user (sudo su - cif)
  1. create your custom.cfg config if you're not upgrading from a previous version:
```
$ cd /opt/cif/etc
$ cp custom.cfg.example custom.cfg
$ chmod 660 custom.cfg
```
  1. perform [cif\_crontool's](Tools_cif_crontool.md) "first run" to prime the database with it's initial intel (should take about 30min).
```
$ time /opt/cif/bin/cif_crontool -f -d && /opt/cif/bin/cif_crontool -d -p daily && /opt/cif/bin/cif_crontool -d -p hourly
```
  1. after this starts, run your first batch of analytics (the first batch might take a few hours up through a few days depending on how much data you have, as long as you keep seeing uuid's fly across the screen.. you're good). If you have more cores/ram, you can increase -t/-m respectively. Sending cif\_analytic a "KILL -INT" (CTRL+C) will spin down the process when it's finished the current batch so you can adjust accordingly. It'll pick back up where it left off.
    * a good setting for less than 8 cores and 8 gig of ram
```
$ time /opt/cif/bin/cif_analytic -d -t 16 -m 2500
```
    * a good setting for 8 cores and 16 gig of ram (this will crush your host for a while, esp your disk io, use htop to keep an eye that you're not swapping yourself to death)
```
$ time /opt/cif/bin/cif_analytic -d -t 32 -m 5000
```
  * when that's finished, run your first batch of feeds (could take anywhere from 20min to 2 hours depending on system, data load, etc)
```
$ time /opt/cif/bin/cif_feeds -d
```
## Finishing up ##
  1. log into the cif user (sudo su - cif) and modify it's cron tab (crontab -e)
```
# set the path
PATH=/bin:/usr/local/bin:/opt/cif/bin

# run analytics
*/5 * * * * /opt/cif/bin/cif_analytic -t 4 -m 4000 &> /dev/null

# pull feed data
05     *       * * * /opt/cif/bin/cif_crontool -p hourly -T low &> /dev/null
30     00      * * * /opt/cif/bin/cif_crontool -p daily -T low &> /dev/null

# update the feeds
45     *       * * * /opt/cif/bin/cif_feeds &> /dev/null
```
  1. or if you want to setup logging (as an example)
```
# set the path
PATH=/bin:/usr/local/bin:/opt/cif/bin

# run analytics
*/2 * * * * /opt/cif/bin/cif_analytic -d -t 4 -m 4000 >> /home/cif/analytics.log 2>&1

# pull feed data
05     *       * * * /opt/cif/bin/cif_crontool -p hourly -T low >> /home/cif/crontool_hourly.log 2>&1
30     00      * * * /opt/cif/bin/cif_crontool -p daily -T low >> /home/cif/crontool_daily.log 2>&1

# update the feeds
45     *       * * * /opt/cif/bin/cif_feeds >> /home/cif/feeds.log 2>&1
```