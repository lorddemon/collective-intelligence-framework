# Introduction #

This describes the various dynamically generated data-sets within the framework. These data-sets can be used as:

  * IDS rules
  * name-server zones
  * firewall rules
  * and more...

Before you begin, make sure you review the [Taxonomy](Taxonomy.md) page. This will help with measuring your risk tolerance and which feed combinations you should use.

The simplest feed to get started with is the [botnet Infrastructure](FeedsBotnet#Infrastructure.md) feed. Typically botnet infrastructure is tagged with a severity of [high](TaxonomySeverity#High.md), meaning, if you combine this with a [high confidence](TaxonomyConfidence#85_-_94.md) (85-100) observation, it's likely that you're dealing with a compromised host.
# Output Plugins #
The perl-client has a number of "output plugins" available:
```
$ cif -h
Usage: perl /opt/local/bin/cif -q xyz.com

...
    -p  --plugin:           output plugin (html,bindzone,table,snort,iptables,pcapfilter,csv,raw), default: table
```

This functionality allows feeds to be written out in other formats removing the need to "parse and convert" the feeds to meet your target device requirements. These formats include:
  * snort rules
  * csv
  * raw json
  * bindzone
  * etc

If another format is required, please let us know. These plugins are typically 10-20 lines of code and are easy to write. All that's required is a sample of the format (eg: example rules, etc). For devices that have the ability to incorporate perl/python code into their operation (eg: NFSEN, bro, etc..), we are writing code that will hook directly into the API allowing these tools to pull the data in directly, rather than having to write them out to rules, re-parse, etc...

```
$ cif -q infrastructure/network -s medium -p snort
alert ip any any -> 2.56.0.0/14 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:1; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL102988; priority:5; )
alert ip any any -> 31.11.43.0/24 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:2; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL113323; priority:5; )
alert ip any any -> 31.222.200.0/21 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:3; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL111681; priority:5; )
alert ip any any -> 41.221.112.0/20 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:4; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL73618; priority:5; )
...
```

# Details #
By default, servers will deliver feeds with a severity of "high" and a confidence of "95" respectively by default. These paramaters can be over-written at the command-line (typically with the -s and -c flags) or via the [API](API.md).

Because of this, **the botnet infrastructure (high severity, high confidence) feed will remain relatively small or even empty** until users enter fairly confidence data either via manual submission, or a known, high-quality data-set is added to the system. This is by design, novice users of the system should use these feeds as starter-feeds to get a feel for the system with-out having to deal with too many false-positives.

Advanced users, who understand their organizations risk tolerance can dig into the more advanced botnet feeds [page](FeedsBotnet.md) or even the [API](API#Common_Parameters.md) to override these default values.

_You'll need the [PerlClient](http://code.google.com/p/collective-intelligence-framework/wiki/PerlClient) installed to pull these feeds. There is also a [PythonClient](http://code.google.com/p/collective-intelligence-framework/wiki/PythonClient) that has less features, but can be used at your own risk for right now._

## Infrastructure ##
IP-based threats
### Detection ###
  * detecting botnet controller communication
```
$ cif -q infrastructure/botnet -c 85
```
### Mitigation ###
  * mitigation against infection (exploit pages, etc, should use domain or url based where possible)
```
$ cif -q infrastructure/malware -c 85 -s medium
```
  * mitigation against brute-force and/or network scanner-based threats
```
$ cif -q infrastructure/scan -s medium -c 85
```
  * mitigation against suspicious networks (known criminal hosting, could lead to infection)
```
$ cif -q infrastructure/network -s medium -c 85
```

## Domains ##
Domain-based threats
### Detection ###
  * detecting botnet controller communication:
```
cif -q domain/botnet -c 85
```
### Mitigation ###
  * mitigating against infections (exploit pages, etc):
```
cif -q domain/malware -c 85 -s medium
```
## Urls ##
URL-based threats
### Detection ###
  * detecting botnet controller traffic:
```
cif -q url/botnet -c 85
```
### Mitigation ###
  * mitigation against infection (exploit pages, etc):
```
cif -q url/malware -s medium -c 85
```
  * mitigation against phishing url lures
```
cif -q url/phishing -s medium -c 85
```