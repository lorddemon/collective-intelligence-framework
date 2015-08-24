

# Generating API Keys #

See [this](Tools_cif_apikeys_v0.md) for information on generating API keys.

# Feed Generation #
  1. for performance reasons, feeds are aggregated via cron
  1. each feed is aggregated, compressed and base64 encoded, then inserted into a database for more efficient delivery
  1. each set of client libraries is designed to detect this encoding and transparently decode/decompress the feeds and return the results to your output without any extra setup
  1. because of this, larger feeds may take longer to decode/decompress on your client, but results in less load against the data-warehouse and the servers
  1. to make sure you have feeds in your system after [loading them](http://code.google.com/p/collective-intelligence-framework/wiki/ServerInstall_v0#Load_Data):
```
$ psql -U postgres -d cif
cif=# select id,uuid,restriction,confidence,severity,description from feed order by confidence desc, severity desc limit 5;
  id   |                 uuid                 | restriction | confidence | severity |                                   description                                    
-------+--------------------------------------+-------------+------------+----------+----------------------------------------------------------------------------------
 13303 | b3684eef-1090-57b9-9083-818c7dd93b5a | private     |         95 | high     | botnet infrastructure high severity 95% confidence private feed
 13371 | 6d8f4ffc-1be4-52ab-8f9c-99406e699e13 | private     |         95 | high     | infrastructure high severity 95% confidence private feed
 13302 | 7eada5c5-a2e9-5d67-9551-e689f4623a1d | private     |         95 | high     | infrastructure high severity 95% confidence private feed
 13414 | e4854ad0-4b61-5bc7-9833-a19fd68c2394 | private     |         95 | high     | domain high severity 95% confidence private feed
 13372 | a768925a-7e19-50a2-9eca-5ad8892e8b71 | private     |         95 | high     | botnet infrastructure high severity 95% confidence private feed
```

# Special Flags #
## definitions ##
  * **apikey**
  * **severity** (high|medium|low) -- see [here](TaxonomySeverity.md) for a list of definitions
  * **restriction** (private|need-to-know|public|default)
  * **nolog** (1|0) -- don't log the query
  * **nomap** (0|1) -- don't map permissions by default (if you have this turned on at the server level)
  * **confidence** -- lowest confidence to return -- see [here](TaxonomyConfidence.md) for a list of definitions
  * **guid** -- run query under the "group permission" specified
  * **limit** -- default server limit for queries is ~ 500, re-set this limit

## examples ##
```
https://example.com/api/infrastructure?apikey=1234&severity=medium& confidence =40
https://example.com/api/domain?apikey=1234&confidence=95
https://example.com/api/infrastructure/network?apikey=1234&severity=medium&confidence=40&nolog=1
https://example.com/api/domain/botnet?apikey=1234&severity=medium&confidence=40&guid=1234&restriction=need-to-know
https://example.com/api/url/botnet?apikey=1234&restriction=private&severity=high&confidence=85
https://example.com/api/1.2.3.0/24?apikey=1234&limit=200&severity=medium&confidence=50
```

# Feeds #

See [this](TaxonomyImpact.md) for a list of definitions

## Domain ##
  * domain/
  * domain/fastflux
  * domain/malware
  * domain/nameserver

## Infrastructure ##
  * infrastructure/
  * infrastructure/asn
  * infrastructure/botnet
  * infrastructure/malware
  * infrastructure/network
  * infrastructure/phishing
  * infrastructure/scan
  * infrastructure/spam
  * infrastructure/suspicious

## Malware ##
  * malware/

## Urls ##
  * url/
  * url/botnet
  * url/malware
  * url/phishing

## Whitelists ##
These feeds are **NOT** included in their respective top-level feeds (eg: domain/ and infrastructure/)
  * domain/whitelist
  * infrastructure/whitelist

# Query Examples #
|Query|Example|
|:----|:------|
|domain|example.com:443/api/domain/example.com?apikey=xx-xx-xx-xx|
|domain|example.com:443/api/example.com?apikey=xx-xx-xx-xx|
|malware|example.com:443/api/malwawre/71eb3bcdb9dcc0fe4a0089db62692318?apikey=xx-xx-xx-xx|
|malware|example.com:443/api/71eb3bcdb9dcc0fe4a0089db62692318?apikey=xx-xx-xx-xx|
|url  |example.com:443/api/url/246c9fa16cdc19411ace5cb43c301d2c?apikey=xx-xx-xx-xx|
|ipv4 |example.com:443/api/192.168.1.1?apikey=xx-xx-xx-xx|
|ipv4-net|example.com:443/api/infrastructure/192.168.1.0/24?apikey=xx-xx-xx-xx|
|ipv4-net|example.com:443/api/192.168.1.0/24?apikey=xx-xx-xx-xx|