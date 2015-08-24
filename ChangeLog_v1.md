## ChangeLog ##
the official, up-to-date changelog can now be found [here](https://github.com/collectiveintel/cif-v1/blob/master/ChangeLog)

### RC3 - 2013-05 ###
#### libcif ####
```
 - swiched bin/cif to use env instead of /usr/bin/perl (better for other UNIX's)
 - added no_decode and new_only flags to client (see doc)
 - added JSON STDIN support (for calling from cmdline or other langs)
 - added exclude_assessment filter flag to client (see doc)
 - repurposed -p 'raw' from json to native array struct
 - misc other fixes
```
#### libcif-dbi ####
```
 - misc doc fixes to cmd line tools
 - added rename function to cif_apikeys
 - security fix to uuid-specific lookup
 - improved make purgedb arguments (from DELETE to TRUNCATE)
 - fixed spam and spamvirtising schemas
 - misc regex fixes
 - added make rebuilddb command that rebuilds all schemas with the exception of apikeys and groups
 - changed default feed retention policies
```

#### cif-smrt ####
```
 - fixes to RelatedActivity and AlternativeID via the IODEF spec
 - fixes to the "fail open" flags
 - cleaned up ParseXML code
 - [ahoying] cleaned up to ParseRSS code [https://github.com/collectiveintel/cif-smrt/issues/52]
 - added carboncopy features (along with multi-iodef array responses from iodef-pb-simple)
 - pushed "sharewith" / "carboncopy" down to iodef-pb-simple
 - [akreffett] cleaned up http proxy support [https://github.com/collectiveintel/cif-smrt/issues/39]
 - added LWPx::ParanoidAgent support (better timeout support if a feed pull get stuck)
 - whitelist urls bugfix
```

#### cif-router ####
```
 - minor response fixes
 - throttling option for larger data-sets when someone wants to use the legacy api
 - json output cleanup
 - minor installation fixes
```

### RC2 - 2013-01 ###
  * complied CentOS6, Ubuntu12 and Debian6 doc
  * merged everything under the cif-v1 tree in github (cif-router, etc are all submodules)
  * cleaned up the installer as one automake "meta installer"
  * (libcif-dbi) split out asn, cc and rir support as non-default options (save space)
  * (cif-router) added legacy JSON keypair query/submission support (on by default)
  * cleaned up some of the configs
  * (cif-smrt) added proxy support
  * (cif-smrt) re-mapped detecttime to reporttime (more accurate)
  * (cif-test-framework) added to do basic i/o tests for new installations
  * (libcif) re-factored the client a bit, more plugabble for various query / transport types
  * (libcif) back-ported the 'advanced config' from cif-v0
  * (libcif) re-factored and added to the debug / logging functions
  * (rt-cifminimal) updated to work with cif-v1
  * other various performance enhancements

### RC1 - 2012 ###
  * renamed cif-perl to libcif
  * renamed cif-dbi-perl to libcif-dbi
  * merged cif-client to libcif
  * libcif now provides (implements) cif-protocol
  * libcif now provides HTTP transport
  * renamed cif-router-perl to cif-router
  * renamed cif-smrt-perl to cif-smrt
  * misc bugfixes to cif-smrt
  * migrated Iodef::Pb to be auto-generated and implemented in Iodef::Pb::Simple
  * added simple access control to feed data-types (eg: domain, infrastructure, malware) based on apikey (eg: key can only access one of the feeds if you allow it, no query)

### B3 ###
  * re-architected cif-smrt for better memory + thread support via ZeroMQ
  * merged cif\_analytics into cif-smrt as "postprocessors", disabled by default, enabled by use of the '-P' flag in cif\_smrt
  * improved feed generation support
  * removed direct "dbi" database integration, now uses submission support in cif-client and cif-router
  * added submission support to cif-router
  * added key expiration to cif-router / cif-apikeys

### B2 ###
  * re-architected how feeds are generated (enabled only)
  * re-architected how ip-addresses are index'd (removed strict postgres dep)

### B1 ###
  * Moved from JSON to Google Protocol Buffers (protobuf)
  * added compression (compress-snappy)
  * enabled remote database connectivity
  * split out:
    * cif-perl (core cif messaging protocol)
    * cif-dbi-perl (core database interface)
    * cif-smrt (formally cif\_feedparser)
    * cif-router (formally CIF::WebAPI)
  * turned cif-router into a driver framework (eg: HTTP, ZeroMQ are just plugins and can be swapped out)
  * simplified the CIF::Router api (removed severity and restriction from the api)
  * simplified the query data model, most things are now just sha1 hash lookups (with the exception of ipv4/6 addresses)
  * less "index" tables to swap in and out of memory, faster lookups, ip-addr's will follow in upcoming beta's