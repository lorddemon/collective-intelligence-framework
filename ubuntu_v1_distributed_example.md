test
<font color='red'>
<h1>Unstable</h1>
<ul><li>Should be factually correct, needs readability work done<br>
</font></li></ul>

# Preamble #

The individual components of CIF can be separated out to provide better scalability, redundancy, etc. In this example, the database will be separated out from the rest of the CIF components, and a second database will be added for redundancy. This is the [Two Servers diagram](http://code.google.com/p/collective-intelligence-framework/wiki/CIFInfrastructureDiagram#Two_servers), with an additional Postgresql server.

Although there are many possible methods of implementation, this guide will have the following parameters:
  * All nodes will be using Ubuntu 12.04 LTS Server 64-bit
  * The Postgresql server(s) will be following the "Large Install" disk layout
  * The second section is structured such that the secondary Postgresql server could be added to the environment at any future point after the initial setup with minimal downtime for the primary DB server.

The two sections of this document are:
  * Section 1 - A CIF front end node and a Postgres back end node
  * Section 2 - Section 1 with a second Postgresql server for HA/DR purposes

# Section 1 - Install CIF on one node, Postgresql on another #

## Systems in use ##

  * CIF front-end: cif1.example.com - 10.0.0.1
  * Primary DB: db1.example.com - 10.0.1.1

## Disk Layout ##
  * Since the CIF node will not be hosting any data and uses relatively little disk I/O, a default disk layout is acceptable.
  * For the Postgresql server, follow recommendations in the [CIF Disk Layout guide for large installs](http://code.google.com/p/collective-intelligence-framework/wiki/DiskLayout_v1#Large_Install).
  * **NOTE:** If you will be doing replication between two databases, increase the size of the pg\_xlog partition from 2GB to 5GB. This will allow for additional wal segments which allows for a greater amount of time that a secondary server can be turned off or disconnected and still automatically sync back up when connectivity is restored.

## CIF prereq installation - cif1.example.com ##

### Introduction ###
This assumes a clean install of Ubuntu 12.04 with all base system updates applied. There are some duplicates between the system wide deps and CPAN, this can be ignored. In some cases we need an upgraded version of the module and by installing the system-wide dependency first, it installs some of the other deps via that mechanism too, simplifying the install. Sometimes it's easier to get bugs fixes into CPAN faster than the more stable Debian/Ubuntu tree.

### Static Address ###
Make sure your instance has a static v4 address (e.g. 10.0.0.1)
### ZeroMQ 2.x ###
There are two different tree's in the zeromq family, 2.x and 3.x, CIF v1 leverages the 2.x family right now. Future versions may be built against the CZMQ api and may be built against either code base. The instructions below will take care of the installation.
### Perl 5.14 CPAN ###
Newer versions of Perl / CPAN have made some [changes](http://sipb.mit.edu/doc/cpan/) to their configuration defaults that affect how packages are installed. If you're not familiar with customizing CPAN, you'll need to start out by boot-strapping your own config. This way it'll install dependencies system wide by default instead of to a local home directory. CIF may be adapted to this in the future, but this is a work-around for now.
  1. boot-strap the default CPAN config
```
$ sudo su - root
$ mkdir -p /root/.cpan/CPAN
$ vi /root/.cpan/CPAN/MyConfig.pm
```
  1. copy / paste the following into `MyConfig.pm`
```
$CPAN::Config = {
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[/root/.cpan/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[/bin/bzip2],
  'cache_metadata' => q[1],
  'check_sigs' => q[0],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[/root/.cpan],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[/usr/bin/gpg],
  'gzip' => q[/bin/gzip],
  'halt_on_failure' => q[0],
  'histfile' => q[/root/.cpan/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[0],
  'keep_source_where' => q[/root/.cpan/sources],
  'load_module_verbosity' => q[none],
  'make' => q[/usr/bin/make],
  'make_arg' => q[],
  'make_install_arg' => q[],
  'make_install_make_command' => q[/usr/bin/make],
  'makepl_arg' => q[INSTALLDIRS=site],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[sudo ./Build],
  'mbuildpl_arg' => q[--installdirs site],
  'no_proxy' => q[],
  'pager' => q[/usr/bin/less],
  'patch' => q[/usr/bin/patch],
  'perl5lib_verbosity' => q[none],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[/root/.cpan/prefs],
  'prerequisites_policy' => q[follow],
  'scan_cache' => q[atstart],
  'shell' => q[/bin/bash],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'tar' => q[/bin/tar],
  'tar_verbosity' => q[none],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[/usr/bin/wget],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
```
  1. when you run the first "perl -MCPAN install ..." command, it will auto-configure a list of local CPAN mirrors for you
### Dependencies Installation ###
  1. Install the base dependencies from the Ubuntu repositories (as root). Note the installation of `postgresql-client` instead of just `postgresql`.
```
$ aptitude -y install rng-tools build-essential postgresql-client apache2 apache2-threaded-dev gcc g++ make libexpat1-dev libapache2-mod-perl2 libclass-dbi-perl libnet-cidr-perl libossp-uuid-perl libxml-libxml-perl libxml2-dev libmodule-install-perl libapache2-request-perl libdbd-pg-perl bind9 libregexp-common-perl libxml-rss-perl libapache2-mod-gnutls libapreq2-dev rsync libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libmime-lite-perl libfile-type-perl libtext-csv-perl libio-socket-inet6-perl libapr1-dbg libdate-manip-perl libtry-tiny-perl libclass-accessor-perl pkg-config vim libjson-xs-perl perl-modules libdigest-sha-perl libsnappy-dev libdatetime-format-dateparse-perl liblwp-protocol-https-perl libtime-hires-perl libnet-patricia-perl libnet-ssleay-perl liblog-dispatch-perl libregexp-common-net-cidr-perl libtext-table-perl libdatetime-perl libencode-perl libmime-base64-perl libhtml-table-perl libzmq-dev libzmq1 libzeromq-perl libssl-dev
```
  1. Install the remaining perl dependencies from CPAN (as root)
```
$ PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Abuse::Utils,Linux::Cpuinfo,Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Net::Abuse::Utils::Spamhaus,Net::DNS::Match,Snort::Rule,Parse::Range,Log::Dispatch,Net::SSLeay,ZeroMQ,Sys::MemInfo,LWP::Protocol::https'
```

### Resolver Config ###
Configure the static interface to use 127.0.0.1 as the nameserver. Bind will be configured next.

  1. edit /etc/network/interfaces. Replace (or add) dns-nameservers with 127.0.0.1
```
$ sudo vi /etc/network/interfaces
```
```
# The primary network interface
iface eth0 inet
        dns-nameservers 127.0.0.1
```
  1. Restart networking
```
$ sudo ifdown eth0 && sudo ifup eth0
```
  1. Verify resolveconf
```
$ cat /etc/resolv.conf
```
    * Should look similar to:
```
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 127.0.0.1
```

### Configure Bind ###
  * Follow this link to configure Bind9: [Bind setup](http://code.google.com/p/collective-intelligence-framework/wiki/BindSetup_v1)

### Default CIF user ###
Create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser --disabled-password --gecos '' cif
```

### CIF Router Configuration (Apache) ###
Some of the "CIF" values will be created later in the doc, for now just follow the config as is, don't worry about creating things like "/home/cif" etc.
  1. enable the default-ssl site (debian):
```
$ sudo a2ensite default-ssl
$ sudo a2enmod apreq
$ sudo a2enmod ssl
```
  1. unless you know what you're doing with virtual hosts, comment out the port-80 stuff in /etc/apache2/ports.conf
```
$ sudo vi /etc/apache2/ports.conf
```
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
$ sudo vi /etc/apache2/sites-available/default-ssl
```
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
+      PerlRequire /opt/cif/bin/http_api.pl
+      Include /etc/apache2/cif.conf
....
```
  1. create your config at /etc/apache2/cif.conf, which should look like:
```
$ sudo vi /etc/apache2/cif.conf
```
```
<Location /api>
    SetHandler perl-script
    PerlResponseHandler CIF::Router::HTTP
    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>

```
  1. add your "www-data" user (whoever apache is set to run under) to the group "cif" (/etc/group):
```
$ sudo adduser www-data cif
```

### Random Number Generator ###
The "rng-tools' service helps with random number generation (mainly used for generating security certificates in bind and apache, speeds up the entropy process).
  1. modify /etc/default/rng-tools to use /dev/urandom as the seed
```
$ echo 'HRNGDEVICE=/dev/urandom' | sudo tee -a /etc/default/rng-tools
```
  1. restart rng-tools
```
$ sudo service rng-tools restart
```

## Postgresql prereq setup ##
This section covers setting up the Postgresql server, and testing connectivity from the CIF node and Postgresql node

### Postgresql server setup - db01.example.com ###
This assumes a clean install of Ubuntu 12.04 with all base system updates applied.

### Dependencies Installation ###
  1. Install the base dependencies from the Ubuntu repositories (as root)
```
$ aptitude -y install postgresql postgresql-contrib
```

### Directory Permission Configuration ###
  1. stop the database service
```
$ sudo service postgresql stop
```
  1. Set the appropriate permissions and link the pg\_xlog directory:
```
$ sudo chown postgres:postgres /mnt/archive
$ sudo chown postgres:postgres /mnt/index
$ sudo chown postgres:postgres /mnt/pg_xlog
$ sudo mv /var/lib/postgresql/9.1/main/pg_xlog /var/lib/postgresql/9.1/main/pg_xlog.orig
$ sudo ln -sf /mnt/pg_xlog /var/lib/postgresql/9.1/main/pg_xlog
$ sudo su postgres -c 'cp -vr /var/lib/postgresql/9.1/main/pg_xlog.orig/* /var/lib/postgresql/9.1/main/pg_xlog/.'
```

### Create tablespace "data" folders ###
  1. This is required, otherwise when the installer is ran on the CIF instance, the DB creation will fail
```
$ sudo mkdir -p /mnt/{archive,index}/data
$ sudo chown postgres:postgres /mnt/{archive,index}/data
```

### Postgres Authentication Configuration ###
  1. Modify your postgres config accordingly (note the 'trust' setting, make sure your iptables are up to date!):
```
$ sudo vi /etc/postgresql/9.1/main/pg_hba.conf
```
```
 # (autovacuum, daily cronjob, replication, and similar tasks).
 #
 # Database administrative login by UNIX sockets
-local   all         postgres                          ident sameuser
+local   all         postgres                          trust 
 
 # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
 
 # "local" is for Unix domain socket connections only
-local   all         all                               ident sameuser
+local   all         all                               trust 
 # IPv4 local connections:
-host    all         all         127.0.0.1/32          md5
+host    all         all         127.0.0.1/32          trust
+host	 all	     all	 10.0.0.1/32	       trust
 # IPv6 local connections:
-host    all         all         ::1/128               md5
+host    all         all         ::1/128               trust
```

  1. Modify the postgresql service so that it is listening for IP based connections
```
$ sudo vi /etc/postgresql/9.1/main/postgresql.conf
```
```
-listen_addresses = 'localhost'
+listen_addresses = '*'
```

### Performance Configuration ###
**NOTE:** These recommend numbers have been tested on a machine with 4 cores and 8 GB of ram. During testing we found that these values may be too high for a machine with 4 GB of ram. If you are testing this on a machine with less than 8 GB of ram, you may want to skip this section all together or reduce the numbers these shell script spit out.

  1. Create backups of system files:
```
$ sudo cp /etc/sysctl.conf /etc/sysctl.conf.orig
$ sudo cp /etc/postgresql/9.1/main/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf.orig
```
  1. create shmsetup.sh to configure:
    * shared memory  (to about 1/2 - 2/3 the amount of system ram)
    * control virtual memory overcommit and swappiness
```
$ vi shmsetup.sh
```
```
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
shmall=`expr $phys_pages / 2`
shmmax=`expr $shmall \* $page_size`
echo kernel.shmmax = $shmmax
echo kernel.shmall = $shmall
echo vm.overcommit_memory = 2
echo vm.swappiness = 0
# testing
#echo vm.overcommit_ratio = 100
```
  1. run the script
```
$ /bin/bash shmsetup.sh | sudo tee -a /etc/sysctl.conf
```
  1. reload the kernel settings
```
$ sudo sysctl -p
```
  1. Comment out existing shared\_buffers and max\_connections settings so it can be set below
```
$ sudo sed -i 's/shared_buffers/#shared_buffers/' /etc/postgresql/9.1/main/postgresql.conf
$ sudo sed -i 's/max_connections/#max_connections/' /etc/postgresql/9.1/main/postgresql.conf
```
  1. create postgressetup.sh to configure better defaults for your CIF installation
```
$ vi postgressetup.sh
```
```
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
total_ram_b=`expr $page_size \* $phys_pages`
total_ram_kb=`expr $total_ram_b / 1024`
total_ram_mb=`expr $total_ram_kb / 1024`
ten_percent_total_ram=`expr $total_ram_mb / 10`

work_mem=`expr $total_ram_mb / 8`
shared_buffers=$ten_percent_total_ram
effective_cache_size=`expr $ten_percent_total_ram \* 6`

echo ""
echo ""
echo "#------------------------------------------------------------------------------"
echo "# CIF Setup                                                                    "
echo "#------------------------------------------------------------------------------"
echo "# Rough estimates on how to configured postgres to work with large data sets"
echo "# See the following URL for proper postgres performance tuning"
echo "# http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server"
echo "wal_buffers = 12MB" " # recommended range for this value is between 2-16MB"
echo "work_mem = $work_mem""MB" " # minimum 512MB needed for cif_feed"
echo "shared_buffers = $shared_buffers""MB" "# recommended range for this value is 10% on shared DB server"
echo "checkpoint_segments = 10" " # at least 10, 32 is a more common value on dedicated server class hardware"
echo "effective_cache_size = $effective_cache_size""MB" " # recommended range for this value is between 60%-80% of your total available RAM"
echo "max_connections = 8" " # limiting to 8 due to high work_mem value"
```
  1. run the script
```
$ /bin/bash postgressetup.sh | sudo tee -a /etc/postgresql/X.X/main/postgresql.conf
```

### Testing ###
  1. restart postgres
  1. Check that you can log in locally. On db1.example.com:
```
$ psql -U postgres
```
```
postgres=#
postgres=#\l
                                 List of databases
   Name    |  Owner   | Encoding | Collation  |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres
                                                           : postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres
                                                           : postgres=CTc/postgres
(3 rows)
postgres=#\q
```
  1. if you have issues logging in, it's typically because of a bad pg\_hba.conf file, double check your config and reload postgres.
  1. Check that you can log in from the CIF instance. On cif1.example.com:
```
$ psql -U postgres -h db1.example.com
```
  * Perform the same **\l** query as above, and it should produce the same results
  * if you have issues logging in, it's typically because of a bad pg\_hba.conf file, double check your config and reload postgres. If you cannot connect from the CIF node, check that the postgres server is listening for IP traffic, and that firewall rules are properly set.

### Optional Setup ###
#### Disk Write Performance ####
  1. **EXPERIMENTAL** check your blockdev setting in rc.local:
```
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-archive
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-index
/sbin/blockdev --setra 4096 /dev/mapper/ses--qa1-dbsystem
```

### Helpful Postgresql References ###
  1. http://www.amazon.com/PostgreSQL-High-Performance-Gregory-Smith/dp/184951030X/ref=sr_1_1?ie=UTF8&qid=1321356392&sr=8-1
  1. http://developer.postgresql.org/pgdocs/postgres/kernel-resources.html
  1. http://momjian.us/main/writings/pgsql/hw_performance/
  1. http://www.revsys.com/writings/postgresql-performance.html
  1. http://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server
  1. http://wiki.postgresql.org/wiki/FAQ
  1. http://www.thegeekstuff.com/2009/05/15-advanced-postgresql-commands-with-examples/
  1. http://wiki.postgresql.org/wiki/Disk_Usage

## CIF Installation - cif1.example.com ##
All these tasks are performed on the CIF node. You will not need to do any further setup on the Postgresql node unless you implement a "hot standby"

### Install CIF ###
  1. Configure the following "work around" so that the installer completes successfully
```
$ sudo adduser --disabled-password --no-create-home --gecos '' postgres
$ sudo mkdir -p /mnt/{archive,index}/data
$ sudo chown -R postgres:postgres /mnt/{archive,index}
```
  1. install the latest CIF [package](http://code.google.com/p/collective-intelligence-framework/downloads/list?q=label:RC2)
```
$ tar -xzvf cif-v1-rc2-XXXX.tar.gz
$ cd cif-v1-rc2-XXXX
$ ./configure --with-db-host=db1.example.com && make testdeps
$ sudo make install
$ sudo make initdb
```
  1. Clean up the "work around"
```
$ sudo deluser --force postgres
$ sudo rm -rf /mnt/{archive,index}
```

### Configure CIF environment ###
  1. log in as the cif user:
```
$ sudo su - cif
```
  1. setup your environment $PATH
```
$ vi /home/cif/.profile
```
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
  1. create a ~/.cif
```
$ vi ~/.cif
```
  1. add the following as a template, the API KEYS will be generated in the next section, for now just use the XXX as the placeholders. Note the host address for the db is that of the remote database and not the loopback or localhost.
```
# the simple stuff
[cif_archive]
datatypes = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
#groups = everyone,group1.example.com,group2.example.com,group3.example.com

[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0

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

[db]
# This is the IP of the db1.example.com server
host = 10.0.1.1
user = postgres
password =
database = cif

# if the normal IODEF restriction classes don't fit your needs
[restriction_map]
#public = limited
#need-to-know = amber
#private = red

# logging
# values 0-4
[router]
# set to 0 if it's too noisy and reload the cif-router (apache), only on for RC2
debug = 1
```

### Finishing CIF setup ###
The link below goes to the CIF APIKeys generation and setup. Continue through to the end of the document to complete the CIF installation
  * [APIKey generation and remainder of CIF setup](http://code.google.com/p/collective-intelligence-framework/wiki/ServerInstall_v1#APIKey)

# Section 2 - Bring up a secondary Postgresql server for HA/DR #
This builds upon the previous section and adds a secondary Postgresql server that can be used as a failover in case the primary DB server fails.

For reference, the replication technologies implemented in this section are:
  * [Hot Standby](http://wiki.postgresql.org/wiki/Hot_Standby)
  * [Streaming Replication](http://wiki.postgresql.org/wiki/Streaming_Replication)

The servers used in this example are:
  * CIF front-end: cif1.example.com - 10.0.0.1
  * Primary DB: db1.example.com - 10.0.1.1
  * Seconday DB: db2.example.com - 10.0.1.2

Note the postgresql.conf files have additional configurations that are not immediately needed. These additional configurations reduce the number of steps required if setting up a new standby server if a fail over is initiated.

## Secondary Postgresql server initial setup ##
Follow existing documentation for
  * [Postgresql prereq setup](#Postgresql_prereq_setup.md)
  * [Performance Configuration](#Performance_Configuration.md)

## Allow connectivity between the two Postgresql servers ##

### On both servers ###
  * configure postgres to allow replication connections from the other DB server. Note that 10.0.1.X is the IP address of the other DB server
```
$ sudo vi /etc/postgresql/9.1/main/pg_hba.conf
```
```
# (autovacuum, daily cronjob, replication, and similar tasks).
#
# Database administrative login by UNIX sockets
local   all         postgres                          trust 


# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD


# "local" is for Unix domain socket connections only
local   all         all                               trust 
# IPv4 local connections:
host    all         all         127.0.0.1/32          trust
host     all         all        10.0.0.1/32	      trust
+host   all         all         10.0.1.X/32     trust
# IPv6 local connections:
host    all         all         ::1/128               trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            md5
#host    replication     postgres        ::1/128                 md5
+host    replication     postgres        10.0.1.X/32       trust
```
  * If using iptables, adjust to allow TCP 5432 access between the two DB servers
  * also be sure to restart the postgres service for the changes to take affect
  * create ssh keys for log shipping
```
$ sudo su - postgres
$ ssh-keygen (accept all defaults)
```
  * copy keys to other DB servers
    * since there's no postgres password, you'll need to:
```
$ sudo cp -v /var/lib/postgresql/.ssh/id_rsa.pub /home/<user_account>/.
$ sudo chown <user_account>:<user_account> /home/<user_account>/id_rsa.pub
$ scp /home/<user_account>/id_rsa.pub <other_db_server>:~/dbX_id_rsa.pub (where dbX is db1 or db2...i.e. the hostname of the server the key originated from)
```
  * Then once the key has been trasfered, on the remote server:
```
$ sudo cp -v /home/<user_account>/dbX_id_rsa.pub /var/lib/postgresql/.ssh/authorized_keys
$ sudo chown postgres:postgres /var/lib/postgresql/.ssh/authorized_keys
```
  * from each server, check that the postgres account can ssh into the other machine
```
$ sudo su - postgres
$ ssh dbX.example.com
```

## Configuration replication and fail over between the two servers ##

### on the primary DB server - db1.example.com ###
  * Configure db1 for streaming replication
```
$ sudo vim /etc/postgresql/9.1/main/postgresql.conf
```
```
wal_level = hot_standby
max_wal_senders = 3 # ignored while in standby

archive_mode = on
archive_command = 'ssh db2.example.com "test ! -f /var/lib/postgresql/archivedir/%f" && scp %p db2.example.com:/var/lib/postgresql/archivedir/%f'

# http://wiki.postgresql.org/wiki/Binary_Replication_Tutorial
checkpoint_segments = 64
wal_keep_segments = 128 # ignored while in standby

hot_standby = on # ignored while in master
```
  * at the bottom of the postgresql.conf file, "checkpoint\_segments = 10" was set by the "postgressetup.sh" script. Be sure to comment that out as the above step replaces that value.
  * restart postgresql services

### on the secondary DB server - db2.example.com ###
  * create a copy of the remote DB
```
$ sudo service postgresql stop
$ sudo mv /var/lib/postgresql/9.1/main/ /var/lib/postgresql/9.1/orig_main
$ sudo su - postgres
$ mkdir /var/lib/postgresql/archivedir
$ pg_basebackup -D /var/lib/postgresql/9.1/main/ -P -h db1.example.com -p 5432 -U postgres
$ rm -rf /var/lib/postgresql/9.1/main/pg_xlog
$ ln -s /mnt/pg_xlog /var/lib/postgresql/9.1/main/pg_xlog
$ exit
$ sudo ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/9.1/main/server.crt
$ sudo ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/9.1/main/server.key
```
  * enable hot standby
```
$ sudo vi /etc/postgresql/9.1/main/postgresql.conf
```
```
wal_level = hot_standby                                                         
max_wal_senders = 3 # ignored while in standby                                  
                                                                                
archive_mode = on                                                               
archive_command = 'ssh db1.example.com "test ! -f /var/lib/postgresql/archivedir/%f" && scp %p db1.example.com:/var/lib/postgresql/archivedir/%f'
                                                                                
# http://wiki.postgresql.org/wiki/Binary_Replication_Tutorial                   
checkpoint_segments = 64                                                        
wal_keep_segments = 128 # ignored while in standby                              
                                                                                
hot_standby = on # ignored while in master 
```
  * at the bottom of the postgresql.conf file, "checkpoint\_segments = 10" was set by the "postgressetup.sh" script. Be sure to comment that out as the above step replaces that value.
  * create recovery.conf file
```
$ sudo vi /var/lib/postgresql/9.1/main/recovery.conf
```
```
standby_mode = 'on'
primary_conninfo = 'host=10.0.1.1 user=postgres'
restore_command = 'cp /var/lib/postgresql/archivedir/%f "%p"'
archive_cleanup_command = '/usr/lib/postgresql/9.1/bin/pg_archivecleanup /var/lib/postgresql/archivedir %r'
trigger_file = '/tmp/pgsql.trigger'
```
  * set ownership of recovery.conf
```
$ sudo chown postgres:postgres /var/lib/postgresql/9.1/main/recovery.conf
```
  * restart postgresql service

## How to tell if replication is working ##
  1. on the primary DB server (db1.example.com)
```
$ psql -U postgres
postgres=# SELECT pg_current_xlog_location();
postgres=# \q
```
  1. on the secondary DB server (db2.example.com)
```
$ psql -U postgres
postgres=# SELECT pg_last_xlog_replay_location();
postgres=# \q
```
  1. If the "SELECT" statements show the same value, then replication is working and up to date

## How to fail over to secondary Postgresql server if the primary fails ##

### On the secondary DB server - db2.example.com ###
  1. create the trigger file
```
$ touch /tmp/pgsql.trigger
```

### On the CIF server - cif1.example.com ###
  1. stop any existing cif related tasks or cron jobs. Since the DB is down, they're not doing anything anyway.
  1. edit /home/cif/.cif to point to the secondary db server
```
$ sudo su - cif
$ vi ~/.cif
```
```
[db]
-host = 10.0.1.1
+host = 10.0.1.2
user = postgres
password =
database = cif
```

### Post failover ###
  * after triggering the fail over, the /etc/postgres/9.1/main/recovery.conf file will be deleted
  * the /tmp/pgsql.trigger file can be deleted without issue
  * delete the folder /var/lib/postgresql/archivedir
  * doing this now avoids possible issues once the dead/downed DB server is brought back up as a standby

## How to fail back over to the previously "Primary" DB server ##
Once a failover happens, there needs to be some steps taken to re-enable fail over capabilies (once the primary DB server has been replaced/repaired). For this section, db2.example is the server currently in use, and db1.example.com will be the new hot standby server. Note that this assumes a total failure of the primary DB server. If you have backups of the config files and ssh keys, this could lessen the number of steps in the process.

### Set up db1.example.com ###
  1. [Postgresql prereq setup](#Postgresql_prereq_setup.md)
  1. [Performance Configuration](#Performance_Configuration.md)

### Restoring connectivity between the two servers ###
  * [Allow connectivity between the two Postgresql servers](#Allow_connectivity_between_the_two_Postgresql_servers.md)
  * Note: if you have the ssh keys and pg\_hba.conf file backed up, you can simply restore these to the new db1.example.com. This will avoid having to make changes to these files/folders on db2.example.com

### Restoring replication and fail over abilities ###
This duplicates the above directions for setting up db2 as a slave, only this sets up db1

  * create a copy of the remote DB
```
$ sudo service postgresql stop                                                  
$ sudo mv /var/lib/postgresql/9.1/main/ /var/lib/postgresql/9.1/orig_main       
$ sudo su - postgres                                                            
$ mkdir /var/lib/postgresql/archivedir                                          
$ pg_basebackup -D /var/lib/postgresql/9.1/main/ -P -h db2.example.com -p 5432 -U postgres -W
$ rm -rf /var/lib/postgresql/9.1/main/pg_xlog                                   
$ ln -s /mnt/pg_xlog /var/lib/postgresql/9.1/main/pg_xlog                       
$ exit                                                                          
$ sudo ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/9.1/main/server.crt
$ sudo ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/9.1/main/server.key
```
  * enable hot standby
```
$ sudo vi /etc/postgresql/9.1/main/postgresql.conf                              
```
```
wal_level = hot_standby                                                         
max_wal_senders = 3 # ignored while in standby                                  
                                                                                
archive_mode = on                                                               
archive_command = 'ssh db2.example.com "test ! -f /var/lib/postgresql/archivedir/%f" && scp %p db2.example.com:/var/lib/postgresql/archivedir/%f'
                                                                                
# http://wiki.postgresql.org/wiki/Binary_Replication_Tutorial                   
checkpoint_segments = 64                                                        
wal_keep_segments = 128 # ignored while in standby                              
                                                                                
hot_standby = on # ignored while in master                                      
```
  * at the bottom of the postgresql.conf file, "checkpoint\_segments = 10" was set by the "postgressetup.sh" script. Be sure to comment that out as the above step replaces that value.
  * create recovery.conf file
```
$ sudo vi /var/lib/postgresql/9.1/main/recovery.conf                            
```
```
standby_mode = 'on'                                                             
primary_conninfo = 'host=10.0.1.2 user=postgres'                                
restore_command = 'cp /var/lib/postgresql/archivedir/%f "%p"'                   
archive_cleanup_command = '/usr/lib/postgresql/9.1/bin/pg_archivecleanup /var/lib/postgresql/archivedir %r'
trigger_file = '/tmp/pgsql.trigger'                                             
```
  * set ownership of recovery.conf
```
$ sudo chown postgres:postgres /var/lib/postgresql/9.1/main/recovery.conf       
```
  * restart postgresql service