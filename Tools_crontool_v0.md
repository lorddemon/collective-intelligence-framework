# Introduction #

cif\_crontool is used to call [cif\_feedparser](Tools_feedparser.md). It's similar to cron, as in it:

  1. traverses /opt/cif/etc to find files that end if .cfg
  1. loads up the various sections within each .cfg
  1. tells cif\_feedparser what to do based on those configs

for instance; if you have the following config:

```
[phishtank]
guid = everyone
feed = 'http://data.phishtank.com/data/online-valid.json.gz'
impact = 'phishing url'
source = 'phishtank.com'
fields = 'url,target,phish_detail_url,submission_time'
fields_map = 'address,description,alternativeid,detecttime'
severity = 'medium'
confidence = 85
period = hourly
restriction = 'need-to-know'
alternativeid_restriction = 'public'
first_run = true
```

cif\_crontool tells cif\_feedparser to run the following command:
```
$ cif_feedparser -c /opt/cif/etc/custom.cfg -T medium -f phishtank
```