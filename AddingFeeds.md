# Introduction #

This is a walk-through of adding new feeds. It explains the commonly used configuration values and how they affect feed generation, etc. If you are already familiar with the feed configuration and just need details about all of the configuration values, see the [FeedConfig](http://code.google.com/p/collective-intelligence-framework/wiki/FeedConfig) page.

In this example, the following malware sources will be added:
  * http://isc.sans.edu/tools/suspicious_domains.html - Flags suspicious domains and has a low false positive category.
  * http://urlblacklist.com/?sec=download - General URL categorization. Contains a malware category.

# Details #

## Config Files ##

All of the feeds are loaded from the files in **/opt/cif/etc/** with the extension **.cfg**. Anything without the extension of **.cfg** is ignored.

Configuration files can contain multiple feeds, which provides a way to group related feeds and make use of global variables. However, it's better to create a new config for custom feeds to avoid the process of merging configs whenever CIF is updated.

## Add Global Variables ##

Since all of these feeds will be related to malware, a few of the configuration values can be placed at the top of the config file.
```
impact = 'malware'
severity = 'medium'
detection = daily
period = daily
mirror = '/tmp'
guid = everyone
```

  * **impact** determines how the data will be classified. For a list of the possible impact values, see the [Impact Taxonomy](http://code.google.com/p/collective-intelligence-framework/wiki/TaxonomyImpact).
  * **severity** depends on how your organization views the threat of what the feeds identify. If malware isn't a concern, it makes sense to keep the severity low. See the [Severity Taxonomy](http://code.google.com/p/collective-intelligence-framework/wiki/TaxonomySeverity) for more information.
  * **detection** determines the granularity of the detection time of the items in the feeds. If the data in the source doesn't provide a time stamp for each item, CIF has to assume the item was detected when it first appears in the source. Since these feeds are generated daily, the granularity can only be at the daily level. Possible values are either **hourly** or **daily**.
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
  * **confidence** is the degree of certainty that is given to a source. For the purpose of this demonstration a confidence value of 85 was used to match the default feed generation configuration. As the level of automation and chance for errors increases, the confidence level should be decreased. For example, a feed of all of the IP addresses that an infected machine contacts could contain many false positives and should be given a much lower confidence level. On the other hand, a feed created manually by security professionals that check each entry by hand could be given a confidence level of 90. Save the 91-100 range for sources that have an excellent history of no/very low false positives and a high level of trust. This allows automated action to be taken on data with these very high confidence levels. For more information, refer to the [Confidence Taxonomy](http://code.google.com/p/collective-intelligence-framework/wiki/TaxonomyConfidence).
  * **zip\_filename** specifies the path inside of a compressed archive to the data source.
  * **regex** specifies the regular expression used to extract the values from the data. The urlblacklist source just has one URL per line so nothing special is required. However, the dshield source has comment lines that start with a # and a column title of "Site" that we have to ignore. You should test your regular expressions using a regex tester like the one from [gskinner.com](http://www.gskinner.com/RegExr/).
  * **regex\_values** specifies what the extracted values from the regex correspond to. Both of these sources only provide the URL/Domain and no other information like detect time.
  * **source** specifies the source of the feed. This is usually just the domain name.
  * **alternativeid** is usually the URL or location of the original data point for future reference because the value of **feed** is not returned with queries or feeds.
  * **description** is a few words describing what the data point is.

Most of these configuration values can also be extracted directly from the feed if the relevant data is included. For more examples, visit the [FeedConfig](http://code.google.com/p/collective-intelligence-framework/wiki/FeedConfig) page.

## Final Configuration ##
**/opt/cif/etc/custommalware.cfg**
```
impact = 'malware'
severity = 'medium'
detection = daily
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

A feed can be tested by running **cif\_feedparser** in debug mode with a specific feed and config file. The following example tests the **dshield\_suspiciousdomains** feed in the **/opt/cif/etc/custommalware.cfg** config.
```
~$ /opt/cif/bin/cif_feedparser -c /opt/cif/etc/custommalware.cfg -f dshield_suspiciousdomains -T low -d
isc.sans.edu -- d9a4bff9-229b-543a-8372-b43cb95b3fc6 -- malware dshield low false positive list -- 01n02n4cx00.com...
isc.sans.edu -- 1c03e2c9-8cd8-56ef-a52f-ece9b50715de -- malware dshield low false positive list -- 02c20c8.netsolhost.com...
...[output omitted]...
isc.sans.edu -- 699e0dc9-fe35-5ed4-913f-eadd142f4e7b -- malware dshield low false positive list -- zya.com...
isc.sans.edu -- 7c811c9b-83dc-5de5-8c2c-ee61dd5ec30c -- malware dshield low false positive list -- zz87lhfda88.com...
~$
```
The feedparser should output a line for each item in the data source. If  nothing comes back, verify that the URL to the feed is correct.

## Generate Feeds ##

Generate feeds using this command
```
~$ /opt/cif/bin/cif_feeds -d
```

## Display the Feed ##

Run this command to display a feed of domains
```
~$ cif -q domain -s medium -c 85
```