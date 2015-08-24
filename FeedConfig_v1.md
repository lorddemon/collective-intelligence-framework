

# Introduction #

CIF comes with a variety of pre-built feed configurations, with that there are many ways to create your own configs for various custom feeds. A tutorial on how to create a new feed config file can be found [here](AddingFeeds_v1.md).

# Details #

## File Format ##

All parameters can be a Global parameter or a Feed parameter. If the parameter is specified twice, the Feed parameter will supersede the Global parameter.

```
#Global Parameters
<parameter> = <value>
<parameter> = <value>
<parameter> = <value>

#Feed Parameters
[feed_name]
<parameter> = <value>
<parameter> = <value>
<parameter> = <value>
```


## Common Parameters ##
| Parameter Name | Values | Description | Required |
|:---------------|:-------|:------------|:---------|
| address        | 

&lt;string&gt;

 | This is usually a IP address, URI or domain that are found in feeds of data but is not limited to those data types| yes      |
| alternativeid  | 

&lt;string&gt;

 | usually a url pointing to the original data point (as a reference id) | no       |
| alternativeid\_restriction | 

&lt;string&gt;

 | public, default, need-to-know,private | no       |
| assessment     | 

&lt;string&gt;

 | see [Assessment](TaxonomyAssessment_v1.md) | no       |
| confidence     | 

&lt;int&gt;

 | see [Confidence](TaxonomyConfidence_v1.md) | no       |
| description    | 

&lt;string&gt;

 | short (1-2 space delimited word) description of the activity (eg: tdss spyeye) | no       |
| detection      | 

&lt;string&gt;

 | hourly/daily: useful if you do not have a timestamp | no       |
| detecttime     | 

&lt;string&gt;

 | when the event was detected, most common timestamp formats are valid | no       |
| disabled       | 

&lt;string&gt;

 | true, false | no       |
| feed           | 

&lt;uri&gt;



&lt;filename&gt;

 | `http://example.com/feed.csv` or /tmp/feed.csv | yes      |
| feed\_user     | 

&lt;string&gt;

 | username (Basic authentication) | no       |
| feed\_password | 

&lt;string&gt;

 | password (Basic authentication) | no       |
| goback         | 

&lt;int&gt;

 | number of days to 'goback' over a feed based on the detecttime mapping, default usually 3 days | no       |
| guid           | 

&lt;string&gt;

 | default: 'everyone' unless you know what you're doing | yes      |
| malware\_md5   | 

&lt;string&gt;

 | MD5sum of malicious file | no       |
| malware\_sha1  | 

&lt;string&gt;

 | SHA1sum of malicious file | no       |
| mirror         | 

&lt;string&gt;

 | file path (eg: mirror = '/tmp'), allows for testing to see if the downloaded feed has changed before re-downloading | no       |
| null           | n/a    | Use the null value for columns of data you want to ignore | no       |
| period         | 

&lt;string&gt;

 | hourly/daily: how often the cif\_crontool should pick up this feed (when in doubt, use daily) | no       |
| protocol       | 

&lt;int&gt;



&lt;string&gt;

 | 6 or tcp, 17 or udp | no       |
| portlist       | 

&lt;int&gt;

 | 22 or 80,443 or 6660-7000 | no       |
| reporttime     | 

&lt;string&gt;

 | when the event was reported, most often used when no timestamp is provided. most common timestamp formats are valid | no       |
| restriction    | 

&lt;string&gt;

 | public, default, need-to-know, private | no       |
| severity       | 

&lt;string&gt;

 | see [Severity](TaxonomySeverity_v1.md) | no       |
| source         | 

&lt;string&gt;

 | source of the feed, usually the domain where the feed is from (eg: example.com) | no       |
| zip\_filename  | 

&lt;string&gt;

 | when the feed is a zip file, this should identify what the zip header is | no       |

### Delimited Text Files ###
```
confidence = 65
feed = "http://mirror1.malwaredomains.com/files/domains.txt"
assessment = 'malware'
source = 'malwaredomains.com'
restriction = need-to-know
alternativeid_restriction = public
guid = everyone

[domains]
values = 'null,null,address,description,alternativeid,null'
delimiter = '[\t|\f]'
period = daily
```
| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| values         | 

&lt;csv-string&gt;

 | a comma separated list of parameters |
| delimiter      | 

&lt;string&gt;

 | a sudo-regex that splits up the feed |

### Non-Delimited Text Files ###
```
[sbl]
regex = '^\t\t(\S+)\t(\S+)\t(www.spamhaus.org/sbl/sbl.lasso\?query=sbl\d+)'
regex_values = 'address,description,alternativeid'
confidence = 85
period = daily
```
| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| regex          | 

&lt;string&gt;

 | a regex string that splits up a line feed |
| regex\_values  | 

&lt;csv-string&gt;

 | a csv list that maps to the regex extracted values |

### XML Files ###
```
[cleanmx]
feed = 'http://support.clean-mx.de/clean-mx/xmlviruses.php?'
assessment = 'malware'
source = 'clean-mx.de'
node = entry
elements = 'id,first,md5,virusname,url'
elements_map = 'id,detecttime,malware_md5,description,address'
alternativeid = 'http://support.clean-mx.de/clean-mx/viruses.php?id=<id>'
period = daily
```
| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| node           | 

&lt;string&gt;

 | what xml node we should use as the key node |
| elements       | 

&lt;csv-string&gt;

 | what elements within 

&lt;node&gt;

 we should map out |
| elements\_map  | 

&lt;csv-string&gt;

 | what values we map the 

&lt;elements&gt;

 to |

### JSON Files ###
```
[phishtank]
guid = everyone
feed = http://data.phishtank.com/data/online-valid.json.gz
assessment = 'phishing'
source = 'phishtank.com'
fields = 'url,target,phish_detail_url'
fields_map = 'address,description,alternativeid'
confidence = 85
restriction = 'need-to-know'
alternativeid_restriction = 'public'
```

| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| fields         | 

&lt;csv-string&gt;

 | a comma separated list of the fields |
| field\_map     |  

&lt;csv-string&gt;

 | a comma separated list of the fields |

### More examples ###
Additional example config files can be found [here](https://github.com/collectiveintel/cif-v1/tree/master/cif-smrt/rules/etc) in the cif-smrt source repository.