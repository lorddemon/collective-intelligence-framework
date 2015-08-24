

# Introduction #

This document describes the various configuration options (commonly in /home/cif/.cif) available to the different pieces of the framework

# Details #
## Overview ##
| **section** | **description** | **used by** |
|:------------|:----------------|:------------|
| cif\_archive | api configuration | libcif-dbi, cif\_feed, cif\_apikeys, cif-router |
| client      | local client api configuration | libcif, cif-smrt |
| client\_http | local client http transport (driver) config | libcif, cif-smrt |
| cif\_smrt   | SMRT configuration | cif-smrt    |
| db          | database connection config | libcif-dbi, cif-router, cif\_feed |
| restriction\_map | router API restriction mapping | libcif-dbi, cif\_feed, cif-router |
| router      | router configuration | cif-router  |

## Examples ##
### Single Instance ###
A default (single instance) config example:
```
[cif_archive]

# to enable asn, cc, rir datatypes (requires more storage)
# datatypes = infrastructure,domain,url,email,search,malware,cc,asn,rir
datatypes = infrastructure,domain,url,email,search,malware

# to enable feeds (requires more storage)
# feeds = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
# groups = everyone,group1.example.com,group2.example.com,group3.example.com

[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0

[cif_smrt]
# change localhost to your local domain and hostname respectively
# this identifies the data in your instance and ties it to your specific instance in the event
# that you start sharing with others
name = localhost
instance = cif.localhost

# the apikey for cif_smrt
apikey = XXXXXX-XXX-XXXX 
```

### Client ###
```
[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0
```

### Smrt ###
```
[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0

[cif_smrt]
# change localhost to your local domain and hostname respectively
# this identifies the data in your instance and ties it to your specific instance in the event
# that you start sharing with others
name = localhost
instance = cif.localhost

# the apikey for cif_smrt
apikey = XXXXXX-XXX-XXXX 
```

### Router ###
```
[db]
host = 127.0.0.1
user = postgres
password =
database = cif

# if the normal IODEF restriction classes don't fit your needs
# ref: https://code.google.com/p/collective-intelligence-framework/wiki/RestrictionMapping_v1
[restriction_map]
#white = public 
#green = public 
#amber = need-to-know 
#red   = private         

# logging
# values 0-4
[router]
# set to 0 if it's too noisy and reload the cif-router
debug = 1
```

### Enabling Feeds ###
Wherever cif\_feed (libcif-dbi) is used:
```
[cif_archive]

...

feeds = infrastructure,domain,url,email,search,malware

[cif_feed]
# max size of any feed generated
limit = 50000

# each confidence level to generate
confidence = 95,85,75,65

# what 'role' keys to use to generate the feeds
roles = role_everyone

# how far back in time to generate the feeds from
limit_days = 7

# how many days of generated feeds to keep in the archive
feed_retention = 7
```