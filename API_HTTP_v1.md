# Introduction #


This interface supports the GET/POST methods. The cif-router acts as a proxy for applications where leveraging google protocol buffers is not an efficient option. The cif-router will accept simple JSON keypairs and convert them to the cif-protocol via libcif, then reply back with simple JSON output.
## Caveats ##
### Accept Headers ###
The HTTP transport can be used for non HTTP encoded requests (eg: as a transport for the protocol buffer encapsulated messages). As a result, to leverage the HTTP GET API, requests must have the 'Accept' header set to 'application/json' for the API to respond in the appropriate manner:
```
Accept => 'application/json'
```

### Enabled Default ###
By default, this functionality is turned on. It can be turned off by setting the 'disable\_legacy' option to 1 in the webserver config (apache) if performance degrades.

# Details #
## Common Parameters ##

| Parameter Name | Value | Description |
|:---------------|:------|:------------|
| apikey         | 

&lt;uuid&gt;

 | specify your apikey |
| confidence     | 

&lt;real&gt;

 | filter by confidence, **0-100** |
| restriction    | 

&lt;enum&gt;

 | filter by restriction, **public,need-to-know,private** |
| guid           | 

&lt;uuid&gt;

 | filter by group uuid |
| nomap          | 

&lt;boolean&gt;

 | don't map restriction to your local restriction map |
| nolog          | 

&lt;boolean&gt;

 | don't log the query |

## Authorization ##
This API uses a simple uuid for it's authorization. This key is passed to the api using the 'apikey' parameter:

```
GET https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a
```

## Queries ##
The API uses the 'q' parameter to respond to queries:
```
GET https://cif.example.com/api?q=example.com

GET https://cif.example.com/api?q=infrastructure/botnet

GET https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a&q=192.168.1.1/24
```

## Curl Examples ##

Note: Do not forget to change the following in these examples;
  * Hostname
  * API Key

#### Domain: example.com ####
```
curl -k -i -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36" -H "Accept => application/json" "https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a&q=example.com"
```

#### Feed: infrastructure/botnet ####
```
curl -k -i -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36" -H "Accept => application/json" "https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a&q=infrastructure/botnet"
```

#### CIDR: 192.168.1.1/24 ####
```
curl -k -i -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36" -H "Accept => application/json" "https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a&q=infrastructure/botnet"
```

## Submissions ##
The API leverages the 'POST' function, which should contain a simple JSON key-pair value, as well as the API as cited in the Authorization section.

```
#!/usr/bin/perl

use warnings;
use strict;

use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;

my $url = 'https://cif.example.com/api?apikey=249cd5fd-04e3-46ad-bf0f-c02030cc864a';

my $ua = LWP::UserAgent->new();
$ua->ssl_opts(verify_hostname => 0);
$ua->default_header('Accept' => 'application/json');

my $hash = {
    address     => 'example.com',
    assessment  => 'botnet',
    confidence  => 85,
    description => 'zeus',
};

my $ret = $ua->post($url,Content => encode_json($hash));
warn Dumper($ret);
```