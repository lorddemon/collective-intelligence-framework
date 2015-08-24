Frequently Asked Questions about Feeds.


### When I try to pull a feed, no data is returned? ###
Typically, when you do an initial feed search:
```
$ cif -q infrastructure/scan
```

the client sets the default confidence and severity to "95" and "high" respectively. e.g.

```
$ cif -q infrastructure/scan -c 95 -s high
```

These defaults are set both on the client and the server to:
  1. protect new users from unintentionally putting lower confidence and severity data in their sensors
  1. ensure that data that "makes these feeds" is the type of data where you'd put "boots on the ground" to inspect

Most of the threat intelligence that CIF is configured to pull in by default have a confidence of 85 and a severity of medium. For this reason, you may want try something like this:

```
$ cif -q infrastructure/scan -c 85 -s medium
```

Other CLI examples can be found in the wiki under [Feeds](Feeds_v0.md) -> Types