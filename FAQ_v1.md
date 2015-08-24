**Frequently Asked Questions**



---

### BEFORE YOU BEGIN ###

---

If what you're looking for doesn't appear in the FAQ, here's what info we'll probably need when you ask the list, be sure to post the relevant information:

  * [SEARCH THE MAILING LIST](https://groups.google.com/forum/?fromgroups#!forum/ci-framework), there's a lot of good info in there.
  * steps to reproduce the problem
  * release version of your OS, and of CIF
  * your **obfuscated** config
  * recent apache logs as a result of the problem
  * a list of running processes that might be useful:
```
$ sudo ps aux | grep cif_
```
  * use something like pastebin to paste the relevant information
  * **BE SURE TO OBFUSCATE SENSITIVE DATA**



---

### What native feeds are available out of the box? ###

---

See the [API](API_FeedTypes_v1.md)

### When I try to pull a feed, no data is returned? ###

---

  1. Ensure you are using valid [feed syntax](Feeds_v1.md)
  1. Ensure you have [enabled feed generation](ServerInstall_v1#Enabling_Feed_Generation.md)
  1. Ensure you have [generated the first batch of feeds](ServerInstall_v1#With_Feeds.md)
  1. Ensure you have enabled [cif\_feed in crontab](ServerInstall_v1#Finishing_Up.md)
  1. What is the debug output of the `-q infrastructure/suspicious -c 65` feed?
```
$ /opt/cif/bin/cif -d -q infrastructure/suspicious -c 65

[DEBUG][2013-02-05T19:30:55Z]: generating query
[DEBUG][2013-02-05T19:30:55Z]: query: infrastructure/suspicious
[DEBUG][2013-02-05T19:30:55Z]: sending query
[DEBUG][2013-02-05T19:30:56Z]: decoding...
[DEBUG][2013-02-05T19:30:56Z]: processing: 454 items
[DEBUG][2013-02-05T19:30:56Z]: final results: 454
[DEBUG][2013-02-05T19:30:56Z]: done processing
[DEBUG][2013-02-05T19:30:56Z]: formatting as Table...

feed description:   suspicious infrastructure feed
feed reporttime:    2013-01-19T12:30:05Z
feed uuid:          5e7debaa-24b1-4379-a7c3-24ca58bd6ff3
feed guid:          everyone
feed restriction:   private
feed confidence:    65
feed limit:         50
...
```
  1. What is the debug output the cif\_feed command?
```
$ /opt/cif/bin/cif_feed -d >> /home/cif/cif_feed.log 2>&1
```


---

### Why does the 'guid' field print out as a 'uuid' instead of my group name? ###

---


See: [Group Support](GroupSupport_v1.md) and  [the archive](https://groups.google.com/d/msg/ci-framework/Ya7RqUF6OQ0/jW2BEoD7DR4J)


---

### How much disk space will I need? ###

---

In testing with the default data sets, 23 million records used 6GB in the archive table and 12GB in the index table. That averages out to roughly 1.3 million records per GB. You can reduce disk space over time be pruning the index tables.


---

### Too many open files (signaler.cpp:330) ###

---

#### Ubuntu 12 ####
Edit /etc/security/limits.conf and add:
  * soft nofile 20000
  * hard nofile 30000

reference: https://groups.google.com/d/topic/ci-framework/LDNSJnf6BZg/discussion


---

### Is there an easy way to purge my current repo and start over ###

---


running 'make purgedb' will purge all your tables, except for the apikeys.


---

### Apache spikes to 100% and 'hangs' ###

---


Try switching to apache2-mpm-prefork
#### Ubuntu ####
This will remove apache2-mpm-worker and install -prefork with handles connections a little better but at the cost of performance (negligible). If you begin to see "UNAUTHORIZED" messages, try tuning your apache2.conf MaxClient to 256 and restarting apache (under the 'mpm\_prefork\_module' section).
```
$ sudo aptitude install apache2-mpm-prefork
```


---

### cif\_crontool already running or hung ###

---


  * make sure any cif-crontool / cif-smrt instances are killed (ps aux | grep cif\_crontool)
  * remove any stale lock files:
```
rm /tmp/.cif_crontool.err cif_crontool.lock.*
```

ref: https://groups.google.com/forum/#!topic/ci-framework/5K5KGG7l1EU