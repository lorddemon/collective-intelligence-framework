
# Introduction #

The CIF WebAPI is the programming interface to CIF. You can use this API to integrate CIF based data into your day to day applications (RT, ArcSight, NFSen, Placid, etc...)

# Authorization #

This API uses a simple UUID for it's authorization. This key is passed to the api using the following parameter:
```
&apikey=xxxx
```

# API Calls #
The CIF WebAPI follows a RESTful API design,  meaning that you use standard HTTP methods to retrieve and manipulate resources. For example, to get the profile of a user, you might send an HTTP request like:
```
GET https://cif.example.com:443/api/example.com?apikey=xxxxx

GET https://cif.example.com:443/api/example.com?apikey=xxxxx&severity=high

GET https://cif.example.com:443/api/example.com?apikey=xxxxx&severity=high&confidence=50

GET https://cif.example.com:443/api/example.com?apikey=xxxxx&nolog=1

GET https://cif.example.com:443/api/infrastructure?apikey=xxxxx

GET https://cif.example.com:443/api/domain/botnet?apikey=xxxxx


```
## Common Parameters ##
| Parameter Name | Value | Description |
|:---------------|:------|:------------|
| apikey         | 

&lt;uuid&gt;

 | specify your apikey |
| severity       | 

&lt;enum&gt;

 | filter by severity, **low,medium,high** |
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
| fmt            | 

&lt;string&gt;

 | return format type: **json,table**, default **json** unless the API detects a known web-browser  |

## Common Datatypes ##
### Infrastructure ###
#### Description ####
Commonly used to describe ipv4 and ipv6 based addresses.
#### Examples ####
```
GET https://cif.example.com:443/api/1.1.1.1?apikey=xxxxx
GET https://cif.example.com:443/api/1.1.1.0/24?apikey=xxxxx
GET https://cif.example.com:443/api/infrastructure/botnet?apikey=xxxxx
GET https://cif.example.com:443/api/infrastructure/malware?apikey=xxxxx&confidence=40
GET https://cif.example.com:443/api/infrastructure/phishing?apikey=xxxxx&severity=medium
```
### Domain ###
#### Description ####
Commonly used to describe FQDN based addresses.
#### Examples ####
```
GET https://cif.example.com:443/api/example.com?apikey=xxxxx
GET https://cif.example.com:443/api/test.example.com?apikey=xxxxx
GET https://cif.example.com:443/api/domain/botnet?apikey=xxxxx
GET https://cif.example.com:443/api/domain/malware?apikey=xxxxx&confidence=40
GET https://cif.example.com:443/api/domain/phishing?apikey=xxxxx&severity=medium
```
### Url ###
#### Description ####
Commonly used to describe URI based addresses. To query the api though, your code must:
  1. escape unsafe chars (this is what the data-warehouse does on it's end before normalizing a URI)
  1. lower-case the address
  1. strip off any trailing forward slashes (s/\/$//g)
  1. take the SHA1 hex of the address
  1. query the api using that SHA1-based hash (hex)
```
use Digest::SHA1 qw/sha1_hex/;
use URI::Escape;
my $q = $args{'query'};
if(lc($q) =~ /^http(s)?:\/\//){
    ## escape unsafe chars, that's what the data-warehouse does
    ## TODO -- doc this
    $q = uri_escape($q,'\x00-\x1f\x7f-\xff');
    $q = lc($q);
    $q = sha1_hex($q);
}
```
#### Examples ####
```
GET https://cif.example.com:443/api/98fea5ad2da764a57e3493a78b1dd60061d61e08?apikey=xxxxx
GET https://cif.example.com:443/api/url/botnet?apikey=xxxxx
GET https://cif.example.com:443/api/url/malware?apikey=xxxxx&confidence=40
GET https://cif.example.com:443/api/url/phishing?apikey=xxxxx&severity=medium
```

# Data Formats #
Resources in the CIF WebAPI are represented using JSON+IODEF embedded in a sort of JSON+ATOM data formats.
## Normal Queries ##
For example, retrieving a malicious domain address may result in a response like:
```
{
  "status": 200,
  "data": {
    "feed": {
      "source": "c2a2473aa6adcaf5fd68cb2a02a6d3a1510e7b10",
      "group_map": {
        "8c864306-d21a-37b1-8705-746a786719bf": "everyone",
       },
       "entry": [
         {
           "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
           "version": "1.0",
	   "Incident": {
    	     "Assessment": {
	       "Impact": {
		  "content": "search",
		  "severity": "low"
	       },
	       "Confidence": {
	         "content": "50",
                 "rating": "numeric"
               }
             },
             "purpose": "mitigation",
	     "EventData": {
	       "Flow": {
		  "System": {
		    "Node": {
		      "Address": {
		        "content": "example.com",
			"category": "ext-value",
			"ext-category": "domain"
		      }
		    },
		   "AdditionalData": {
		     "dtype": "string",
		     "content": "A",
		     "meaning": "type"
		   }
		 }
	       }
	     },
	     "IncidentID": {
	       "name": "ce61a4b0-2116-39a7-9a28-3592c192bb90"
	     },
	     "DetectTime": "2011-10-04T00:00:00Z",
             "restriction": "private",
             "Description": "search example.com",
             "AdditionalData": {
               "dtype": "string",
               "content": "0f3421e5-c4d7-323c-af8c-eb32c12f08c5",
               "meaning": "guid"
             }
           },
           "xsi:schemaLocation": "urn:ietf:params:xmls:schema:iodef-1.0",
           "uuid": "6efcfaa6-80ad-547c-a914-0c0ea54dcdbb"
         }
       ],
       "detecttime": "2011-10-04T20:20:45Z",
       "description": "search example.com",
       "restriction": "private"
     }
  },
  "message": ""
}
```
The "feed" structure embeds the IODEF objects as entries.

## Types ##

**Result**
**( object )**
> An object encapsulating a response from the server

  * **data** **(feed object)** - The feed object for the query
  * **message (string)**
  * **status ( integer )** - HTTP response code

**Feed**
**( object )**
> An object containg a query result

  * **description (string)** - description
  * **detectime (string)** - description
  * **entry (single entry object or array of entry objects)** - description
  * **group\_map (group map object)** - description
  * **restriction (string)** - description
  * **source (string)** - description

**Entry**
**( object )**
> description

  * **uuid (string)** - description
  * **version (string)** - description
  * **xmlns:xsi (string)** - description
  * **xsi:schemaLocation (string)** - description
  * **incident (incident object)** - description

**group\_map**
**( object )**
> description

**incident**
**( object )**
> description

  * **AdditionalData (AdditionalIncidentData object)** - description
  * **Assessment (Assessment object)** - description
  * **Description (string)** - description
  * **DetectTime (string)** - description
  * **EventData (EventData object)** - description
  * **IncidentID (IncidentID object)** - description
  * **purpose (string)** - description
  * **restriction (string)** - description

**AdditionalIncidentData**
**( object )**
> description

  * **content (string)** - description
  * **dtype (string)** - description
  * **meaning (string)** - description

**Assessment**
**( object )**
> description

  * **Confidence (Confidence object)** - description
  * **Impact (Impact object)** - description

**EventData**
**( object )**
> description

  * **AdditionalData (AdditionalEventData object)** - description
  * **Flow (Flow object)** - description

**IncidentID**
**( object )**
> description

  * **name (string)** - This is a sha1 uuid hash of the `<value>` as defined by the source parameter found in FeedConfig.
  * **purpose (string)** - description
  * **restriction (string)** - description

**Confidence**
**( object )**
> description

  * **content (integer)** - description
  * **rating (string)** - description

**Impact**
**( object )**
> description

  * **content (string)** - description
  * **severity (string)** - description

**AdditionalEventData**
**( object )**
> description

  * **content (string)** - description
  * **dtype (string)** - description
  * **meaning (string)** - description

**Flow**
**( object )**
> description

  * **System (System object)** - description

**System**
**( object )**
> description

  * **AdditionalData (AdditionalSystemData object)** - description
  * **Node (Node Object)** - description

**AdditionalSystemData**
**( object )**
> description

  * **content (string)** - description
  * **dtype (string)** - description
  * **meaning (string)** - description

**Node**
**( object )**
> description

  * **Address (Address object)** - description

**Address**
**( object )**
> description

  * **category (string)** - description
  * **content (string)** - description
  * **ext-category (string)** - description

## Feed Queries ##
Feed query responses are a little different. When feeds are generated, they tend to be larger than most query responses. To that end, cif\_feeds compresses and base64 encodes the cached feed to the database. When the API replies to a feed query (eg: cif -q domain/malware -s medium -c 85) with a slightly different response:
```
{
  "status": 200,
  "data": {
    "feed": {
      "source": "c2a2473aa6adcaf5fd68cb2a02a6d3a1510e7b10",
      "group_map": {
        "8c864306-d21a-37b1-8705-746a786719bf": "everyone",
       },
       "entry": ["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\n"],
       "detecttime": "2011-10-04T20:20:45Z",
       "description": "search example.com",
       "restriction": "private"
     }
  },
  "message": ""
}
```

The perl library auto-detects this behavior, decodes, decompresses the blob and re-fit's it into the hash response before handing you the response. If you aren't using the GET function within that library, you need to decode this blob yourself using something like zlib and a base64 decoder. This will result in a simple JSON IODEF array. The client libraries also simplify these IODEF documents into simple key-pair hashes. If you're writing your own lib, you'll need to do that too. use the [PerlClient](ClientInstallSourcePerl_v0.md) as a reference.
## Common Parameters ##
  * [ATOM](http://tools.ietf.org/html/rfc4287)
  * [IODEF](http://tools.ietf.org/html/rfc5070)