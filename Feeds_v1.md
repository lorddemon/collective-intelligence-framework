

# Introduction #

This describes the various dynamically generated data-sets within the framework. These data-sets can be used as:

  * IDS rules
  * name-server zones
  * firewall rules
  * and more...

# Details #
By default, servers will deliver feeds with a a confidence of "95" respectively by default. These paramaters can be over-written at the command-line (typically with the -s and -c flags) or via the [API](API.md).

Because of this, **the botnet infrastructure (high confidence) feed will remain relatively small or even empty** until users enter fairly confidence data either via manual submission, or a known, high-quality data-set is added to the system. This is by design, novice users of the system should use these feeds as starter-feeds to get a feel for the system with-out having to deal with too many false-positives.

## Output Plugins ##
The perl-client has a number of "output plugins" available:
```
$ cif -h
Usage: perl /opt/cif/bin/cif -q xyz.com

...
-p  --plugin:           output plugin ('Table','Snort','Csv'), default: Table
```

This functionality allows feeds to be written out in other formats removing the need to "parse and convert" the feeds to meet your target device requirements. These formats include:

| Plugin name | Description |
|:------------|:------------|
| bindzone    | bindzone    |
| bro         | bro (network monitor) |
| csv         | comma separated value |
| html        | html table  |
| iptables    | iptables    |
| json        | json        |
| pcapfilter  | pcap filter |
| snort       | snort rules |
| table       | ascii table |

If another format is required, please let us know. These plugins are typically 10-20 lines of code and are easy to write. All that's required is a sample of the format (eg: example rules, etc). For devices that have the ability to incorporate perl/python code into their operation (eg: NFSEN, bro, etc..), we are writing code that will hook directly into the API allowing these tools to pull the data in directly, rather than having to write them out to rules, re-parse, etc...

The current list of output plugins can be found [here](https://github.com/collectiveintel/iodef-pb-simple-perl/tree/master/lib/Iodef/Pb/Format)

```
$ /opt/cif/bin/cif -q infrastructure/suspicious -c 85 -p snort

# 193.178.120.0/22 [ip address only / not url / not domain rule]
alert ip any any -> 193.178.120.0/22 any ( msg:"need-to-know - suspicious hijacked prefix"; threshold:type limit,track by_src,count 1,seconds 3600; sid:5000000; reference:url,www.spamhaus.org/sbl/sbl.lasso?query=SBL165502; priority:5; )

# 94.63.147.0/24 [ip address only / not url / not domain rule]
alert ip any any -> 94.63.147.0/24 any ( msg:"need-to-know - suspicious hijacked prefix"; threshold:type limit,track by_src,count 1,seconds 3600; sid:5000001; reference:url,www.spamhaus.org/sbl/sbl.lasso?query=SBL127815; priority:5; )

# 176.112.80.0/21 [ip address only / not url / not domain rule]
alert ip any any -> 176.112.80.0/21 any ( msg:"need-to-know - suspicious hijacked prefix"; threshold:type limit,track by_src,count 1,seconds 3600; sid:5000002; reference:url,www.spamhaus.org/sbl/sbl.lasso?query=SBL137006; priority:5; )
...
```

## Usage ##

### Infrastructure ###
IP-based threats

#### Detection ####
  * detecting botnet controller communication
```
$ cif -q infrastructure/botnet -c 85
$ cif -q infrastructure/botnet -c 85 -p iptables
$ cif -q infrastructure/botnet -c 85 -p bro
$ cif -q infrastructure/botnet -c 85 -p snort
```

#### Mitigation ####
  * mitigation against infection (exploit pages, etc, should use domain or url based where possible)
```
$ cif -q infrastructure/malware -c 85
$ cif -q infrastructure/malware -c 85 -p iptables
$ cif -q infrastructure/malware -c 85 -p bro
```
  * mitigation against brute-force and/or network scanner-based threats
```
$ cif -q infrastructure/scan -c 85
$ cif -q infrastructure/scan -c 85 -p snort
$ cif -q infrastructure/scan -c 85 -p iptables
```

### Domains ###
Domain-based threats

#### Detection ####
  * detecting botnet controller communication:
```
$ cif -q domain/botnet -c 85
$ cif -q domain/botnet -c 85 -p snort
$ cif -q domain/botnet -c 85 -p bindzone
```
#### Mitigation ####
  * mitigating against infections (exploit pages, etc):
```
$ cif -q domain/malware -c 85
$ cif -q domain/malware -c 85 -p bindzone
$ cif -q domain/malware -c 85 -p snort
```
### Urls ###
URL-based threats

#### Detection ####
  * detecting botnet controller traffic:
```
$ cif -q url/botnet -c 85
$ cif -q url/botnet -c 85 -p snort
$ cif -q url/botnet -c 85 -p bro
```

#### Mitigation ####
  * mitigation against infection (exploit pages, etc):
```
$ cif -q url/malware -c 85
$ cif -q url/malware -c 85 -p snort
$ cif -q url/malware -c 85 -p csv
```
  * mitigation against phishing url lures
```
$ cif -q url/phishing -c 85
$ cif -q url/phishing -c 85 -p snort
$ cif -q url/phishing -c 85 -p csv
$ cif -q url/phishing -c 85 -p html
```

# Advanced #

The feeds documented above are the most common type of feeds used by the CIF community. CIF has the capability to generate many other feeds assuming it is [configured to do so](ServerInstall_v1#Enabling_Feed_Generation.md) and it is [taking in data](AddingFeeds_v1.md) of the correct assessment.

For a complete list of the native feed types available, visit the [FeedTypes](API_FeedTypes_v1.md) page.

**Note:** We cannot stress this enough, CIF will only generate feeds under the following conditions:

  1. it is configured to generate feeds
  1. it is configured to generate feeds at the specified confidence level
  1. it is ingesting data with the necessary assessment and confidence level

It is fully expected that your CIF instance will not generate many of the possible feeds due to the reasons above. [In CIFv2](https://github.com/collectiveintel/cif-v2/issues/19), we hope to make feeds less ambiguous.