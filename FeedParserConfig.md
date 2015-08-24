# Introduction #

cif\_feedparser...

# Details #

## File format ##

Default configuration

```
[cif_feeds]
maxrecords = 10000
severity_feeds = high,medium
confidence_feeds = 95,85
apikeys = role_everyone_feed
max_days = 2
disabled_feeds = hash,rir,asn,countrycode,malware
```

## Common Parameters ##
| Parameter Name | Values | Description | Required |
|:---------------|:-------|:------------|:---------|
| maxrecords     | 

&lt;int&gt;

 | Maximum number of records in the feed | xxx      |
| severity\_feeds | 

&lt;string&gt;

 | The severity levels you want to generate feeds for | xxx      |
| confidence\_feeds | 

&lt;int&gt;

 | The confidence levels you want to generate feeds for | xxx      |
| apikeys        | 

&lt;string&gt;

 | xxx         | xxx      |
| max\_days      | 

&lt;int&gt;

 | How many days you want an observation to stay in a feed | xxx      |
| disabled\_feeds | 

&lt;string&gt;

 | xxx         | xxx      |