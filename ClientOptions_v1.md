# Introduction #

There are two main client options when accessing a CIF instance. They are:

  * [Native Client](ClientInstall_v1.md)
  * [Firefox/Chrome](ClientInstall_Browser_v1.md)

# Native Client #
The native client is a simple library that provides the [api](API_v1.md) as well as a command line interface for interacting with a cif instance. This usually installs cleanly on native UNIX based systems (including OSX). Win32/64 users should use the Firefox/Chrome plugin.

```
$ cif -q 130.201.0.0/16
WARNING: This table output not to be used for parsing, see "-p plugins" (via cif -h)
WARNING: Turn off this warning by adding: 'table_nowarning = 1' to your ~/.cif config

feed description:   search 130.201.0.0/16
feed reporttime:    2013-05-08T11:03:00Z
feed uuid:          29fafb8a-2d20-418e-ae9c-5c91aa05e293
feed guid:          everyone
feed restriction:   private
feed confidence:    0
feed limit:         50

restriction|guid    |assessment|description          |confidence|detecttime          |reporttime          |address       |alternativeid_restriction|alternativeid                                        
restricted |everyone|search    |search 130.201.0.0/16|50        |2013-05-08T11:03:00Z|2013-05-08T11:03:00Z|130.201.0.0/16|                         |                                                     
privileged |everyone|suspicious|hijacked prefix      |95        |2013-04-30T13:43:00Z|2013-04-30T13:43:00Z|130.201.0.0/16|limited                  |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
```

# Firefox/Chrome #
The browser plugins allow for simple interaction with the api via it's legacy HTTP/JSON [interface](API_HTTP_v1.md). The API auto-detects the requests and translates between google protocol buffers and JSON behind the scenes for the client. This is the simplest way to interact with a CIF instance for all users.

![https://collective-intelligence-framework.googlecode.com/files/browser_plugin.png](https://collective-intelligence-framework.googlecode.com/files/browser_plugin.png)