**Table of Contents**


# What is the Collective Intelligence Framework? #

---


CIF is a cyber threat intelligence management system. CIF allows you to combine known malicious threat information from many sources and use that information for identification (incident response), detection (IDS) and mitigation (null route). The most common types of threat intelligence warehoused in CIF are IP addresses, domains and urls that are observed to be related to malicious activity.

This framework pulls in various data-observations from any source; create a series of messages "over time" (eg: reputation). When you query for the data, you'll get back a series of messages chronologically and make decisions much as you would look at an email thread, a series of observations about a particular bad-actor.

CIF helps you to parse, normalize, store, post process, query, share and produce data sets of threat intelligence.

The original idea came from from:

http://bret.appspot.com/entry/how-friendfeed-uses-mysql

# Introductions #

---

  * [toolsmith: Collective Intelligence Framework](http://holisticinfosec.blogspot.com/2012/07/toolsmith-collective-intelligence.html)
  * [SES - Security Event System](http://www.ren-isac.net/ses/)
  * [more](http://code.google.com/p/collective-intelligence-framework/wiki/CommunityExamples)

# the Process #

---

## Parse ##

CIF supports [ingesting](AddingFeeds_v1.md) many different sources of data of the same type; for example data sets or “feeds” of malicious domains. Each similar dataset can be marked with different attributes like source and confidence to name a few.

## Normalize ##

Threat intelligence datasets often have subtle differences between them. CIF [normalizes](TaxonomyAssessment_v1.md) these data sets which gives you a [predictable](TaxonomyConfidence_v1.md) experience when leveraging the threat intelligence in other applications or processes.

## Post Process ##

CIF has many [post processors](https://github.com/collectiveintel/cif-v1/tree/master/cif-smrt/lib/CIF/Smrt/Plugin/Postprocessor) that derive additional intelligence from a single piece of threat intelligence. A simple example would be that a domain and an IP address can be derived from a URL ingested into CIF.

## Store ##

CIF has a database schema that is highly optimized to store billions of records of threat intelligence. CIF v1 uses a ["schema-less"](http://backchannel.org/blog/friendfeed-schemaless-mysql) storage system on top of a RDBMS.

## Query ##

CIF can be queried via a [web browser](ClientInstall_Browser_v1.md), [native client](ClientInstall_v1.md) or directly using the [API](API_v1.md). CIF has a database schema that is highly optimized to perform queries against a database of millions of records.

## Share ##

CIF supports users, groups and api keys. Each threat intelligence record can be tagged to be shared with specific group of users. This allows the sharing of threat intelligence among [federations](Recipe_FederatedSharing_v1.md).

## Produce ##

CIF supports creating new [data sets](Feeds_v1.md) from the stored threat intelligence. These data sets can be created by type and confidence. CIF also supports [whitelisting](Whitelist_v1.md) during the feed generation process.

# Papers / Presentations #

---


A list of papers / presentations can be found [here](Preso.md)