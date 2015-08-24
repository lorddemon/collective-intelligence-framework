# Sharing Threat Intelligence #

At some point you may want to share your threat intelligence with others. This may be public like [Zeustracker](https://zeustracker.abuse.ch/) or with trusted private partners or communities. This is a introductory guide to sharing threat intelligence.

## Baseline ##

---


#### Method of Sharing ####

The most common way to share threat intelligence in 2014 is to place the intelligence in a CSV file and make it available via http or https with basic auth. A harder way to share threat intelligence in 2014 is to use SMTP and possibly GPG, which requires your partners to parse SMTP messages and possibly [unencrypt](https://github.com/giovino/perl-mail-gpg-example) if encrypted.

One of the goals of the CIF project is to make it easier to share threat intelligence, once familiar with CIF (which is no small feat), CIF can give you a lot of advanced capabilities essentially for free.

#### Most Specific Indicator ####

Whenever possible share the most specific indicator you have. If you have:

  * URL - share the malicious URL
  * IP address - share the ip address, port and protocol
  * FQDN - share the FQDN

All too often someone will start with a malicious URL then resolve the A record or strip out the domain and share the IP address or domain as the malicious indicator. Due to shared hosting, compromised servers or compromised web applications, often the most specific indicator is the best indicator (most confident) of potential compromise.

## Minimum Sharing ##

---


There is a bare minimum that one should strive for when sharing threat intelligence. You can share less than what is described below but the entity on the other side will have to make a lot of assumptions and these assumptions will likely lead to a decreased level of confidence in the shared threat intelligence.

#### Common Parameters ####

| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| address        | 

&lt;string&gt;

 |IP address, URI, domain |
| assessment     | 

&lt;string&gt;

 | see [Assessment](TaxonomyAssessment_v1.md) |
| detecttime     | 

&lt;string&gt;

 | ISO 8601 preferred (2013-06-18T10:10:00Z) |
| portlist       | 

&lt;int&gt;

 | 22,25,80    |
| protocol       | 

&lt;int&gt;

 

&lt;string&gt;

 | 6 or tcp, 17 or udp |

#### Infrastructure ####

```
#address,portlist,protocol,detecttime,assessment
"192.168.1.1","22","tcp","2013-06-18T10:10:00Z","scanner"
"192.168.10/24","80,443","tcp","2013-06-17T08:01:56Z","botnet"
```

#### Domain ####

```
#address,detecttime,assessment
"example.com","2013-06-16T12:00:00Z","botnet"
"car.example.com","2013-06-16T12:00:00Z","malware"
"google.com","2013-06-01T12:00:00Z","whitelist"
```

#### URI ####

```
#address,detecttime,assessment
"http://www.example.com/bad.php","2013-06-16T12:00:00Z","malware"
"https://controller.example.com/bad.php","2013-06-16T12:00:00Z","botnet"
```

## Advanced Sharing ##

---


As you mature in your threat intelligence sharing capabilities, you may find that your partners need more than the bare minimum as described above. Below are some common parameters found in mature threat intelligence feeds.

#### Common Parameters ####
| Parameter Name | Values | Description |
|:---------------|:-------|:------------|
| alternativeid  | 

&lt;string&gt;

 | usually a url pointing to the original data point (as a reference id) |
| alternativeid\_restriction | 

&lt;string&gt;

 | [rfc5070](http://www.ietf.org/rfc/rfc5070.txt) (public, need-to-know, private) or [TLP](http://www.us-cert.gov/tlp)|
| confidence     | 

&lt;int&gt;

 | see [Confidence](TaxonomyConfidence_v1.md) |
| description    | 

&lt;string&gt;

 | short (1-2 space delimited word) description of the activity (eg: tdss spyeye) |
| restriction    | 

&lt;string&gt;

 | [rfc5070](http://www.ietf.org/rfc/rfc5070.txt) (public, need-to-know, private) or [TLP](http://www.us-cert.gov/tlp)|
| severity       | 

&lt;string&gt;

 | see [Severity](TaxonomySeverity_v1.md) |
| source         | 

&lt;string&gt;

 | source of the feed, usually the domain where the feed is from (eg: example.com) |

## Sharing with CIF ##

---


As mentioned above, one of CIF's goals is to make it easier to share threat intelligence. If you deploy a CIF instance and feed your threat intelligence to CIF, what capabilities does CIF give you in regard to sharing threat intelligence?

  * Create users with [API keys](Utilities_v1#cif_apikeys.md)
  * Create [groups](GroupSupport_v1.md) to share threat intelligence selectively
  * [Generate](ServerInstall_v1#Enabling_Feed_Generation.md) [feeds](Feeds_v1.md) of threat intelligence
  * Support many [output types](Feeds_v1#Output_Plugins.md), not only CSV
  * Give your partners an [API](API_v1.md) to program against
  * [Whitelisting](Whitelist_v1.md) capabilities