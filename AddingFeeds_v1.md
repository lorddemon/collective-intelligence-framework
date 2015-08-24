

# Introduction #

This is a walk-through of adding new feeds. It explains the commonly used configuration values and how they affect feed generation, etc. If you are already familiar with the feed configuration and just need details about all of the configuration values, see the [FeedConfig](FeedConfig_v1.md) page.

In this example, the following malware sources will be added:
  * http://isc.sans.edu/tools/suspicious_domains.html - Flags suspicious domains and has a low false positive category.
  * http://urlblacklist.com/?sec=download - General URL categorization. Contains a malware category.

# Details #

## Config Files ##

All of the feeds are loaded from the files in **/opt/cif/etc/** with the extension **.cfg**. Any files without the extension of **.cfg** are ignored.

Configuration files can contain multiple feeds, which provides a way to group related feeds and make use of global variables. However, it's better to create a new config for custom feeds to avoid the process of merging configs whenever CIF is updated.

## Add Global Variables ##

Since all of these feeds will be related to malware, a few of the 'global' configuration values can be placed at the top of the config file.
```
assessment = 'malware'
period = daily
mirror = '/tmp'
guid = everyone
```

  * **assessment** determines how the data will be classified. For a list of the possible assessment values, see the [Assessment Taxonomy](TaxonomyAssessment_v1.md).
  * **period** is how often CIF will read the source. This can be done **hourly** or **daily**.
  * **mirror** is a location to cache a local copy of the feed to prevent repeated downloads if the file hasn't updated at the source.
  * **guid** specifies the CIF group that will have access to the data.
## Add the Feeds ##

Add each feed into the configuration file. Feeds are delimited by the name of the feed in brackets.

```
[dshield_suspiciousdomains]
feed = 'http://isc.sans.edu/feeds/suspiciousdomains_Low.txt'
confidence = 85
regex = '^((?!Site)[^#]\S+)'
regex_values = address
source = 'isc.sans.edu'
alternativeid = 'http://isc.sans.edu/feeds/suspiciousdomains_Low.txt' 
description = 'dshield low false positive list' 

[urlblacklist]
feed = 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist'
confidence = 85
zip_filename = 'blacklists/malware/urls'
regex = '^(\S+)' 
regex_values = address
source = 'urlblacklist.com'
alternativeid = 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist'
description = 'urlblacklist.com malware urls'

```
  * **feed** specifies the URL of the data source. This can also be a path to a local file.
  * **confidence** is the degree of certainty that is given to a source. For the purpose of this demonstration a confidence value of 85 was used to match the default feed generation configuration. As the level of automation and chance for errors increases, the confidence level should be decreased. For example, a feed of all of the IP addresses that an infected machine contacts could contain many false positives and should be given a much lower confidence level. On the other hand, a feed created manually by security professionals that check each entry by hand could be given a confidence level of 90. Save the 91-100 range for sources that have an excellent history of no/very low false positives and a high level of trust. This allows automated action to be taken on data with these very high confidence levels. For more information, refer to the [Confidence Taxonomy](TaxonomyConfidence_v1.md).
  * **zip\_filename** specifies the path inside of a compressed archive to the data source.
  * **regex** specifies the regular expression used to extract the values from the data. The urlblacklist source just has one URL per line so nothing special is required. However, the dshield source has comment lines that start with a # and a column title of "Site" that we have to ignore. You should test your regular expressions, you could use a perl one liner like this:
```
perl -ne '/^((?!Site)[^#]\S+)/ and print "$1\n"' suspiciousdomains_Low.txt
```
  * **regex\_values** specifies what the extracted values from the regex correspond to. Both of these sources only provide the URL/Domain and no other information like detect time.
  * **source** specifies the source of the feed. This is usually just the domain name.
  * **alternativeid** is usually the URL or location of the original data point for future reference because the value of **feed** is not returned with queries or feeds.
  * **description** is a few words describing what the data point is.

Most of these configuration values can also be extracted directly from the feed if the relevant data is included. For more examples, visit the [FeedConfig](FeedConfig_v1.md) page.

## Final Configuration ##
**/opt/cif/etc/custommalware.cfg**
```
assessment = 'malware'
period = daily
mirror = '/tmp'
guid = everyone

[dshield_suspiciousdomains]
feed = 'http://isc.sans.edu/feeds/suspiciousdomains_Low.txt'
confidence = 85
regex = '^((?!Site)[^#]\S+)'
regex_values = address
source = 'isc.sans.edu'
alternativeid = 'http://isc.sans.edu/feeds/suspiciousdomains_Low.txt' 
description = 'dshield low false positive list' 

[urlblacklist]
feed = 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist'
confidence = 85
zip_filename = 'blacklists/malware/urls'
regex = '^(\S+)' 
regex_values = address
source = 'urlblacklist.com'
alternativeid = 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist'
description = 'urlblacklist.com malware urls'

```

## Testing a Feed ##

A feed can be tested by running **cif\_smrt** in debug mode with a specific feed and config file. The following example tests the **dshield\_suspiciousdomains** feed in the **/opt/cif/etc/custommalware.cfg** config.
```
~$ /opt/cif/bin/cif_smrt -d -v 2 -r /opt/cif/etc/custommalware.cfg -f dshield_suspiciousdomains -T low

[DEBUG][2013-05-02T18:01:54Z][]: fail closed: 0
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::init]: postprocessing disabled...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: setting up zmq interfaces...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: sending ctrl warm-up msg...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: starting sender thread...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: creating 1 worker threads...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: done...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::process]: running preprocessor routine...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::preprocess_routine]: parsing...
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::parse]: pulling feed: http://isc.sans.edu/feeds/suspiciousdomains_Low.txt
[DEBUG][2013-05-02T18:01:54Z][CIF::Smrt::worker_routine]: starting worker: 2
[DEBUG][2013-05-02T18:01:57Z][CIF::Smrt::worker_routine]: uuid: cafb5431-17ba-4e2b-b86c-11f0b8a86213 - 2013-05-02T18:01:55Z - 000007.ru - malware - dshield low false positive list
[DEBUG][2013-05-02T18:01:57Z][CIF::Smrt::worker_routine]: uuid: 2616bdcc-94dc-4cf1-a647-fedb59262d96 - 2013-05-02T18:01:55Z - 000023p.rcomhost.com - malware - dshield low false positive list
[DEBUG][2013-05-02T18:01:57Z][CIF::Smrt::worker_routine]: uuid: 8e53de25-81da-496a-b2f8-536625ea9528 - 2013-05-02T18:01:55Z - 000cc.com - malware - dshield low false positive list
[DEBUG][2013-05-02T18:01:57Z][CIF::Smrt::worker_routine]: uuid: 380a3a49-84b5-49b4-a8d7-89c4b9d9a4d9 - 2013-05-02T18:01:55Z - 000e0062fb44cd5b277591349e070277.info - malware - dshield low false positive list
...
```
cif\_smrt should output a line for each item in the data source. If  nothing comes back, verify that the regex and URL to the feed is correct.

## Generate Feeds ##

Generate feeds using this command
```
~$ /opt/cif/bin/cif_feed -d
```

## Display the Feed ##

Run this command to display a feed of domains
```
~$ cif -q domain -c 85
```