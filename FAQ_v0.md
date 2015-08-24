# Frequently Asked Questions #



## Net::DNS UNIX issue ##
```
I got an error that it couldn't find Net::DNS::Resolver::Linux.pm... I 
linked Unix.pm to linux.pm and now I get this: 

Can't locate object method "init" via package "Net::DNS::Resolver" at 
/usr/local/lib/perl/5.14.2/Net/DNS/Resolver.pm line 44. 
```
see: https://groups.google.com/d/topic/ci-framework/3LNLcKfMelI/discussion

## Unstable Doc ##
This typically means that the documentation isn't regularly tested with newer updates. Although it should basically work, it could be missing a few dependencies here as the underlying architecture changes.

## Is there an existing public instance where I can test things out? ##
A 3rd-party contributed public instance can be found [here](http://www.josehelps.com/p/feeds.html).

## Can't connect to my\_ip\_server:443 (certificate verify failed) ##
If you're using a self-signed TLS/SSL certificate, you need to add the following to your ~/.cif config:
```
[client]
host = ...
apikey = ...
verify_tls = 0
```

## When I try to pull a feed, no data is returned? ##
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

## When I search for a URL, I get back a list of hashes? ##

When you search for a URL, a few things happen:

  1. the client "normalizes" the url (escaping and encoding certain characters)
  1. the client then hashes the url (md5/sha1)
  1. the client then searches the system for the hash rather than the url itself (cleaner with the REST API)

The results can be a bit non-obvious. You may get back a list of references for that URL, you may get back a list of searches for that hash. You may also get a combination of the two.

## Is there a client for OS X? ##

The PerlClient and PythonClient work well on OS X. The PythonClient can take a little bit of work to get installed (cython throws some errors from time to time), but if you're just looking for a simple CLI, test out the PerlClient.

## XML Parser errors ##

Sometimes, usually with the CleanMX feed you might see something like:
```
:173111: parser error : Sequence ']]>' not allowed in content
/mojodownloads.info/dl/index.cgi?cid=114&eid=001&key=mojodownloads1227A]]></url>
                                                                                ^
:173111: parser error : internal error
/mojodownloads.info/dl/index.cgi?cid=114&eid=001&key=mojodownloads1227A]]></url>
                                                                                ^
:173111: parser error : Extra content at the end of the document
/mojodownloads.info/dl/index.cgi?cid=114&eid=001&key=mojodownloads1227A]]></url>
```

This is normal and should be ignored. CleanMX doesn't appear to be producing valid XML from time to time. It's something that needs to be addressed, but have no control over at the moment. See:

https://groups.google.com/forum/?hl=en&fromgroups#!topic/ci-framework/jCgvMZkTOVs

## cif\_feed JSON errors ##

This is usually due to a ~/.cif mis-config make sure your [cif\_feeds](cif_feeds.md) section has this line in it:

```
[cif_feeds]
...
disabled_feeds = hash,rir,asn,countrycode,malware
```

discussion list [reference](https://groups.google.com/d/msg/ci-framework/6ugUQuYnWNw/omavkCYPAI0J)

## Threads Crash with "Too many open files" ##
here's the [fix](http://blog.thecodingmachine.com/content/solving-too-many-open-files-exception-red5-or-any-other-application)

## /svn/trunk doesn't exist ##

We've moved the repo's to [github](http://github.com/collectiveintel/cif-v0)

## database connection password errors ##

Can't insert new CIF::WebAPI::APIKey: DBI connect('database=cif;host=localhost','postgres',...) failed: fe\_sendauth: no password supplied at /usr/local/share/perl/5.14.2/Ima/DBI.pm line 328.

make sure you've read the postgres section of [this](http://code.google.com/p/collective-intelligence-framework/wiki/ServerInstall_v0#Required_Services)