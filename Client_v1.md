# Before you Begin #
**BY DEFAULT, ALL QUERIES ARE ANONYMOUSLY LOGGED**

When performing a query, your apikey is hashed (sha1-uuid) and the basics of your search are logged by the system.  This allows other local CIF users to see when there might be interest in a specific piece of intelligence, but not necessarily any concrete "feed" type data. Searches show up like this:
```
$ cif -q example.com -p table
feed description:   search example.com
feed reporttime:    2013-02-05T15:05:41Z
feed uuid:          b028b9a1-4cb4-43fe-9e54-9269f4bf2a0c
feed guid:          everyone
feed restriction:   private
feed confidence:    0
feed limit:         50

restriction|guid    |assessment|description       |confidence|detecttime          |reporttime          |address    |alternativeid_restriction|alternativeid
private    |everyone|search    |search example.com|50        |2013-02-05T15:05:41Z|2013-02-05T15:05:41Z|example.com|                         |

```