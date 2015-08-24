# Table Of Contents #


# Overview #

This is an example document for sharing data between two entities (sites, orgs, federations...)

In this use case scenario, there is an entity running CIF (CIF West) that we (CIF East) want to receive network threats from to proactively block SSH scanners. Each entity has its own CIF instance that receives threat data, normalizes it, and produces feeds for CIF clients.

![http://collective-intelligence-framework.googlecode.com/svn/wiki/CIFdiagram.png](http://collective-intelligence-framework.googlecode.com/svn/wiki/CIFdiagram.png)

# Prerequisites #

## CIF Servers ##

This use case requires two CIF server installations - one for the entity that will be sharing data (CIF West), and another for the one that will import the data (CIF East).

Use the following [ServerInstall guide](ServerInstall_v0.md) to setup the CIF servers.

If you don't want to use all of the public feeds that are enabled by default, use the following commands to append .example to the end of all of the feed configs to disable them.
```
cd /opt/cif/etc/
for f in *.cfg; do mv $f $f.example; done
```

## CIF Client on the SSH server ##

In this use case, the SSH server needs the CIF client  to receive feeds from CIF East to automatically block SSH scanner addresses. Use the following guide to install the [Perl Client](ClientInstallSourcePerl_v0.md)

# Configuration #

## CIF West Instance to Share SSH Feeds ##

To control the data that CIF West shares to CIF East, a new group needs to be created that only has access to unrestricted SSH threat data that it aggregates.

To add a new user as a member of a different group, use the **cif\_apikeys** command with the **-g** and **-G** options. (Note: cif\_apikeys -h will show all of the options)
```
cif@CIFwest:~$ cif_apikeys -a -u myuser@cifeast.local -g sshgroup -G sshgroup
```
The command above adds a new user (myuser@cifeast.local) on the CIF West instance and makes it a member of the group sshgroup and sets its default group to sshgroup. (Note: Groups aren't added independently, they are implicitly created when users are added to them)

Now the group sshgroup needs to be given access to some of the data sources.  This is done by duplicating the sources with a new guid value. Refer to the following configuration (**/opt/cif/etc/knownsshattackers.cfg**) for example:
```
severity = 'high'
confidence = 95
restriction = 'restricted'
detection = hourly

[drg_ssh_everyone]
impact = 'scanner'
values = 'source,address,detecttime,null'
portlist = 22
source = 'dragonresearchgroup.org'
protocol = tcp
description = 'ssh'
feed = 'http://dragonresearchgroup.org/insight/sshpwauth.txt'
regex = "^\\d+\\s+\\|\\s+[\\S|\\s]+\\|\\s+(\\S+)\\s+\\|\\s+(\\S+\\s\\S+)\\s+\\|"
regex_values = 'address,detecttime'
alternativeid = 'http://dragonresearchgroup.org/insight/sshpwauth.txt'
guid = privategroup

[drg_ssh_sshgroup]
impact = 'scanner'
values = 'source,address,detecttime,null'
portlist = 22
source = 'dragonresearchgroup.org'
protocol = tcp
description = 'ssh'
feed = 'http://dragonresearchgroup.org/insight/sshpwauth.txt'
regex = "^\\d+\\s+\\|\\s+[\\S|\\s]+\\|\\s+(\\S+)\\s+\\|\\s+(\\S+\\s\\S+)\\s+\\|"
regex_values = 'address,detecttime'
alternativeid = 'http://dragonresearchgroup.org/insight/sshpwauth.txt'
guid = sshgroup
```

The **drg\_ssh\_sshgroup** section is the added configuration required to give sshgroup access to the data from that source. (_Note: If a config value is mostly the same throughout the file, it can be set globally at the top. For example, if this file was for one source, everything could be moved to the top except for the guid to reduce duplication._)

At this point, sshgroup can access the data, but no feeds are generated for sshgroup (i.e. it can send queries for addresses, etc, but queries for feeds like 'infrastructure' will not return data). To generate feeds for sshgroup, the .cif configuration file in the cif home directory (_/home/cif/.cif_) needs to be modified to generate a feed for an additional API key.

Because the feed generation configuration is based on users, a new user should be generated as a member of the sshgroup just for the purpose of generating feeds. The myuser@cifeast.local user could be used, but then configuration changes would be necessary if the user was ever deleted. By having a user specifically for feeds, members of sshgroup can change without affecting feed generation. Use the cif\_apikeys tool to generate this new 'role key' user.
```
cif@CIFwest:~$ cif_apikeys -a -u role_ssh_group -g sshgroup -G sshgroup
```
Now edit the feed generation section of the /home/cif/.cif and include the role\_ssh\_group user in the apikeys value.
```
[cif_feeds]
maxrecords = 10000
severity_feeds = high,medium
confidence_feeds = 95,85
apikeys = role_everyone_feed, role_sshgroup_feed
max_days = 2
disabled_feeds = hash,rir,asn,countrycode,malware
```
Feeds will be generated for the group sets of these 'role' users.

## Import the CIF West Feed into CIF East ##

Currently (and ironically), the CIF feed parser doesn't directly support directly adding another CIF server as a feed source due to the encoding used in the [API](API_v0#Feed_Queries.md). The CIF client has to be run on the CIF server to pull the feed from the other server, format it and write it to a file so it can be imported. This work is being completed in the next version of CIF (v1).

Create a client configuration file that contains the API key and the URL to the CIF server that the feed will be pulled from. The following example client config is named cifclient\_west.cfg:
```
[client]
host = https://<address of CIF West>:443/api
apikey = <API key for myuser@cifeast.local user created on CIF West>
timeout = 60
verify_tls = 0
```
You can then test it by running `cif -C cifclient_west.cfg -q infrastructure`, which should either return feed data or nothing (i.e. no errors).

Then setup a script as a [cron](https://help.ubuntu.com/community/CronHowto) job to run the client hourly and save the output as JSON to a file. The following script is an example that saves medium severity feeds of any confidence to /home/cif/WEST\_infrastructure.json:
```
#!/bin/bash
cd /home/cif/
/usr/local/bin/cif -C cifclient_west.cfg -q infrastructure -p raw -s medium -c 1 > WEST_infrastructure.json
```

Now that the data is being saved to a file, it can be added like a regular feed for the CIF server to parse. Create a feed config (e.g. _/opt/cif/etc/cifwest.cfg_) and enter the following options:
```
[cifwest_infrastructure]
feed = '/home/cif/WEST_infrastructure.json'
fields = 'purpose,asn,rir,portlist,alternativeid,detecttime,address,alternativeid_restriction,severity,description,confidence,restriction,prefix,impact'
fields_map = 'purpose,asn,rir,portlist,alternativeid,detecttime,address,alternativeid_restriction,severity,description,confidence,restriction,prefix,impact'
source = 'CIFWEST'
guid = everyone
detection = hourly
```

The CIF East server will now import all of the data from CIF West. The 'source' field is being overwritten to 'CIFWEST' in this case, but it could be imported from the feed by adding it to the 'fields' and 'fields\_map' options instead.

More details on the feed configuration options can be found [here](FeedConfig_v0.md)

## SSH Server to Retrieve the Infrastructure Feeds from the CIF Server ##

The SSH server should have the CIF client already installed at this point. Run **cif -V** to print the client version. It should be at least v0.1104 for this tutorial.

For the SSH server to receive the necessary feed, it needs the API key that was setup during the initial server install. (_You can run **cif\_apikeys -L** on the CIF server to find it._)

Create the configuration file for the client. By default, the client looks for the configuration file in the home directory of the user running it. In this example, the client will be run by root since the output will be used to insert firewall rules. So, create the configuration file **/root/.cif** and with the following contents:
```
[client]
host = https://<address of CIF server>:443/api
apikey = <API key from CIF SERVER>
timeout = 60
verify_tls = 0
```
Note: Set the verify\_tls option to 1 if the certificate used by the CIF server is signed by a trusted certificate authority.

The command `cif -q infrastructure` should now return some results or no response at all if the feeds are empty, but it shouldn't return any errors.

The basic bash script below runs the cif client and automatically inserts the resulting firewall rules:
```
#!/bin/bash
echo "iptables -F" > /root/iptables.sh
echo "iptables -X CIF_IN" >> /root/iptables.sh
echo "iptables -X CIF_OUT" >> /root/iptables.sh
/usr/local/bin/cif -C /root/.cif -q infrastructure/scan -s high -c 95 -p iptables | grep -v '\-j LOG' >> /root/iptables.sh
/bin/bash /root/iptables.sh
```
The first three lines flush the firewall rules to prevent errors from duplicate rules and to make sure old addresses/networks are removed once they are no longer in the feed.
The third line runs the client with the iptables plugin to retrieve the infrastructure/scan feed. It also restricts the results to high severity results with a confidence level of 95 or higher. For more information on these parameters, refer to the following [page](http://code.google.com/p/collective-intelligence-framework/wiki/Feeds)
Rules to log the dropped packets are generated as well. However, a significant amount of traffic from a blocked source can fill logs quickly, so the example above shows how to remove these log rules by piping the cif client output through grep first.
The last line is what ultimately inserts the firewall rules by executing the iptables commands placed in /root/iptables.sh

This script could then be run hourly using [cron](https://help.ubuntu.com/community/CronHowto). Increasing the frequency won't have any benefit since the feeds are only generated by the CIF server on an hourly basis.

## Add a Whitelist ##

Since these data feeds will be used to create firewall rules on servers, it's a good idea to have a method to whitelist known good hosts to prevent them from being blocked even if they generate login failures.

This whitelist doesn't need to be located on any particular server since it's added like any other regular feed. The following configuration(located at **/opt/cif/etc/whitelistedservers.cfg**) points to a whitelist stored as a local file on the CIF server:
```
[cifwestsshwhitelist]
feed = '/opt/serverwhitelist.txt'
impact = 'scanner whitelist'
severity = 'null'
regex = "^(\\S+)$"
regex_values = 'address'
guid = everyone
confidence = 100
detection = hourly
```

That specific configuration expects each IP address (or CIDR notation network) to be entered as an individual line in the **/opt/serverwhitelist.txt** file. To parse a whitelist in a different format, refer to the following guide for designing your own feed parser [config](hFeedConfig_v0.md).

# Appendix #

The following instructions show how to create threat data from local SSH logs and import it into the CIF server so it can be shared with other servers or another entity.

## Configure SSH Servers to Produce Attack Feeds ##

Parsing SSH log files directly for login failures with CIF wouldn't work too well because a single login failure would cause a host to end up in the CIF database.

The Perl script included below parses through a log file (the $authlog variable) for sshd password failures and creates a blacklist of IP addresses that cause more than a threshold (the $threshold variable) of failures in a 60 second window and writes it to a file (the $blacklistfile variable) in a format that's easy for a CIF server to parse.

Put this script in a [cron](https://help.ubuntu.com/community/CronHowto) job that runs hourly. A higher frequency won't help since CIF will only read the blacklist on an hourly or daily basis.

The blacklist needs to be accessible by the CIF server to be parsed. In this case the SSH server is also running Apache2, so the blacklist can be accessed directly via HTTP. Another option could be to push the blacklist to another server using SCP.
Perl Script to Parse SSH logs for excessive failures
```
#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;
use DateTime;

my $authlog = "/var/log/auth.log"; #set the path to the auth.log file here
my $blacklistfile = "/var/www/sshblacklist.txt"; #location to place blacklist
my $threshold = 3; #required number of failed login attempts in a 60 second window to blacklist an IP

open(my $fh, "<", "$authlog")
        or die("Could not open $authlog\n");
my %offenders;
my $hostname="";
while (<$fh>) {
        my $line = $_;
        my @values = split(' ', $line);
        if (scalar(@values)<4){ next;}
        my ($month,$day,$time,$lhostname,$daemon) = @values;
        $hostname = $lhostname;
        if (index($daemon,"sshd")!=0){ next;}
        if (index($line, "Failed password for ")==-1){ next;}
        my $eventdate = str2time("$month $day $time");
        my @fromhalves = split(' from ',$line);
        my @splitsecondtolast = split(' ', $fromhalves[scalar(@fromhalves)-1]);
        my $offendingip = $splitsecondtolast[0];
        if (exists($offenders{$offendingip})){
                push(@{$offenders{$offendingip}},$eventdate);
        } else {
                my @timestamps = ($eventdate);
                $offenders{$offendingip} = \@timestamps;
        }
}
close($fh);

my $dt = DateTime->now;
my $atom = $dt->ymd('-').'T'.$dt->hms(':').'Z';
my $blacklist = "#SSH blacklist generated on $atom\n";

foreach my $offender (keys %offenders){
        my $willblacklist = 0;
        my $lastseen = 0;
        my $t =  $offenders{$offender};
        my @offenses = @$t;
        foreach (@offenses){
                my $ctr=0;
                my $basetime = $_;
                foreach (@offenses){
                        if ($_ < $basetime){ next;}
                        if (($_ - $basetime)>60){ next;}
                        $ctr++;
                }
                if ($ctr >= $threshold){ $willblacklist = 1;}
                if ($basetime > $lastseen){ $lastseen = $basetime;}
        }
        if ($willblacklist){
                $dt = DateTime->from_epoch( epoch => $lastseen );
                $atom = $dt->ymd('-').'T'.$dt->hms(':').'Z';
                $lastseen=$atom;
                $blacklist.="$hostname|||$offender|||$lastseen|||sshfailure\n";
        }
}

open(my $fh_blacklist, ">", "$blacklistfile")
        or die("Could not open $blacklistfile for writing\n");
print $fh_blacklist $blacklist;
close($fh_blacklist);
exit 0;
```

## Import the SSH Attack Feeds into the CIF server ##

On the CIF server, create a new config file in **/opt/cif/etc/** to pull in the SSH attack feed. The following is an example configuration file (**/opt/cif/etc/eastsshservers.cfg**):
```
severity = 'high'
confidence = 95
restriction = 'private'
alternativeid_restriction = 'public'
delimiter = '\|\|\|'
values = 'source,address,detecttime,null'
detection = hourly
impact = 'scanner'
portlist = 22
protocol = tcp

[cifeastssh-everyone]
feed = 'http://yoursshserver.example.org/sshblacklist.txt'
description = 'ssh failures on cifeastssh'
alternativeid = 'http://yoursshserver.example.org/sshblacklist.txt'
guid = everyone
```

Since this configuration file is being specifically used for feeds from SSH servers, many of the options can be placed at the top of the configuration to act as global variables for all of the sources defined in the same file. This way, feeds from other servers or copies for other groups can be added in easily without a lot of duplicated configuration options.