# Introduction #
To add a new group, simply:
  1. associate a users apikey with the new guid (cif
```
$ cif_apikeys -u root@localhost -a -g mygroup1.example.com,everyone -G mygroup1.example.com
```
  1. add "guid = mygroup.example.com" to the feed config you want this applied to:
```
source = 'amada.abuse.ch'
restriction = 'need-to-know'
alternativeid = 'http://amada.abuse.ch/?search=<address>'
alternativeid_restriction = 'public'
confidence = 65
guid = mygroup1.example.com
```
  1. to enable publishing of the group-name (otherwise it will come across as a guid) via the API, simply modify the /home/cif/.cif file on the cif-router and restart the router:
```
# the simple stuff
[cif_archive]
...
# enable your own groups is you start doing data-sharing with various groups
#groups = everyone,group1.example.com,group2.example.com,group3.example.com
groups = everyone,mygroup1.example.com
```

# Details #
CIF supports the use of "unix style permissions" per record

  * enables multi-group and multi-federation support within the system
  * API filters results based on an apikey's association with a group
  * enables larger trust communities to warehouse multi-tiered data (secret handshake vs double secret handshake)
  * enables less trusted users to contribute, query more public data while allowing more trusted users to do the same via the same server/api
  * data can be tagged with a unique identifier (guid) by hashing it's "string name", eg: group1.example.com (similar to how domains work in an LDAP forest)
  * data is tagged much as a unix file is tagged
  * people (or their API keys) are then made part of this group to access the data
  * to scale, we LEFT JOIN the permissions table (small) with the archive table (large) to filter results only that API key (based on their guid membership) can access
  * as long as the permissions table stays relatively small ( < 1mil rows? ), the system scales cleanly.
  * by default, data is placed in the "root" group, which only those in the root group can view
  * "groups" are not maintained, data is simply tagged as it comes in
  * apikeys are associated with groups via the apikeys\_groups table
  * when a query is performed, the LEFT JOIN associates the data with the group
  * 'everyone' group refers to everyone in the system, not the public at large




# References #
  * http://www.xaprb.com/blog/2006/08/16/how-to-build-role-based-access-control-in-sql/
  * http://www.xaprb.com/blog/2006/08/18/role-based-access-control-in-sql-part-2/