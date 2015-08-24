<font color='red'>
<h1>Unstable</h1>
<ul><li>Link to a yet to be created feed type page<br>
</font></li></ul>

Frequently Asked Questions about Feeds.


### When I try to pull a feed, no data is returned? ###

  1. Ensure you are using valid [feed syntax](FeedTypes_v1.md)
  1. Ensure you have [enabled feed generation](ServerInstall_v1#Enabling_Feed_Generation.md)
  1. Ensure you have [generated the first batch of feeds](ServerInstall_v1#With_Feeds.md)
  1. Ensure you have enabled [cif\_feed in crontab](ServerInstall_v1#Finishing_Up.md)
  1. What is the debug output of the `-q infrastructure/suspicious -c 95` feed?
```
$ /opt/cif/bin/cif -d -q infrastructure/suspicious -c 95

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
feed confidence:    95
feed limit:         50
...
```
  1. What is the debug output the cif\_feed command?
```
$ /opt/cif/bin/cif_feed -d >> /home/cif/cif_feed.log 2>&1
```