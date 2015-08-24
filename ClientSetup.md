# Before you Begin #
**BY DEFAULT, ALL QUERIES ARE ANONYMOUSLY LOGGED**

When performing a query, your apikey is hashed (sha1-uuid) and the basics of your search are logged by the system.  This allows other local CIF users to see when there might be interest in a specific piece of intelligence, but not necessarily any concrete "feed" type data. Searches show up like this:
```
$ cif -q example.com
Query: example.com
Feed Restriction: RESTRICTED
Feed Created: 2011-01-20T15:44:14Z

restriction|severity|address    |rdata|type|detecttime            |description       |alternativeid_restriction|alternativeid
RESTRICTED |        |example.com|     |    |2011-01-20 15:00:00+00|search example.com|RESTRICTED               |             
```

# Browser Plugins #
  1. [Google Chrome and Firefox Plugins](BrowserPlugins.md)


# Client Libraries #
  1. PerlClient
  1. PythonClient

# Client Configuration #
  1. GlobalConfigurationFile