Frequently Asked Questions about Feeds.


### When I try to pull a feed, no data is returned? ###
Typically, when you do an initial feed search:
```
$ cif -q infrastructure/botnet
```

the client sets the default confidence and severity to "95" and "high" respectively. These defaults are set both on the client and the server to:
  1. protect new users from unintentionally putting lower confidence and severity data in their sensors
  1. ensure that data that "makes these feeds" is the type of data where you'd put "boots on the ground" to inspect

Typically these feeds should be very small (relative to the 40% confidence feed).

See the Taxonomy section of the wiki for more information on the other possible values. A nice happy medium would be:
```
$ cif -q infrastructure/botnet -c 85
```

although with most public feeds, you'll still rarely see data in this feed unless you're hooking your own data-source up to CIF.

To test and make sure feeds are working; try:
```
$ cif -q infrastructure/network -s medium
```

which will give you a nice mix of SSH scanners as well as the spamhuas.org [DROP](http://www.spamhaus.org/drop/) list.