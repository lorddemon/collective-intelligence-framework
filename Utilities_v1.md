

# Introduction #

This is a basic list of commonly used utilities within the framework and their descriptions. For any of these utilities, the '-h' flag can be processed to give a more specific overview of the utility and it's options.

## Basic ##
#### cif ####

a command line utility used for accessing the API of a cif instance (making queries, etc).

#### cif\_crontool ####

cif\_crontool is used to call cif\_smrt. It's similar to cron, as in it:

  1. traverses /opt/cif/etc to find files that end if .cfg
  1. loads up the various sections within each .cfg
  1. tells cif\_smrt what to do based on those configs

for instance; if you have the following config:

```
[phishtank]
guid = everyone
feed = 'http://data.phishtank.com/data/online-valid.json.gz'
assessment = 'phishing url'
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

cif\_crontool tells cif\_smrt to run the following command:
```
$ cif_smrt -c /opt/cif/etc/custom.cfg -T medium -f phishtank
```

#### cif\_smrt ####

a utility (usually called by cif\_crontool) that reads in configs, parses feed data and transforms it into IODEF.

## Advanced ##

#### cif\_apikeys ####

server-side, command line utility used to generate api keys.

#### cif\_feed ####

server-side, command line utility used (usually via cron) to generate pre-cached feeds (infrastructure/botnet, domain/malware, url/phishing, etc...).

#### cif\_vacuum ####

a server-side tool that vacuums' the cif warehouse (removes older entries, etc).

#### cif\_skel ####

a sample skeleton script used to create new server-side utilities.