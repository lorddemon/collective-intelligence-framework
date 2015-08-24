# Introduction #

Restriction mapping allows you to map the internal IODEF restrictions to other types of restrictions (eg: REN-ISAC, Traffic Light Protocol, etc) on-the-fly with little cif-router configuration and zero client configuration. The cif-router API automatically picks up it's mappings from the config (usually /home/cif/.cif on the router) and publishes them with each query via the API.

When building feeds, if you modify the config to a new mapping, the feeds (cif\_feed) will need to be re-created with the new mapping, since the old mappings are cached with the feed for faster access.

# Details #
## Config ##
  1. in your cif-router config ('/home/cif/.cif' on your cif-router) simply modify the following section
```
# if the normal IODEF restriction classes don't fit your needs
[restriction_map]
white  = public 
green  = public 
amber = need-to-know 
red      = private
```
  1. restart your cif-router (usually the apache process)

## Client ##
On the client, the mappings should show up automatically. To disable the mappings per-query, use the '-N' flag which will show the original IODEF restriction mappings.

# References #
  * https://groups.google.com/d/msg/ci-framework/yc8_3hMNoF0/RW1nC_MPlo4J