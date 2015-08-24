# Introduction #

This document describes the native feed types available in v1.

For more detail on each description, visit the [assessments](TaxonomyAssessment_v1.md) page.

# Details #
## Infrastructure ##
|**type**|**description**|
|:-------|:--------------|
|infrastructure/botnet|botnet controllers|
|infrastructure/scan|bruteforce, port-scan, etc|
|infrastructure/phishing|things that host phishing|
|infrastructure/malware|things that exploit, drop malware|
|infrastructure/spam|things that host/send spammers|
|infrastructure/spamvertising|things that related to viagra|
|infrastructure/suspicious|things that are unknown but not friendly|
|infrastructure/whitelist|amazon, google, facebook, etc (alexa top 10000ish)|
|infrastructure/warez|things that aid in piracy that could cause us pain from the RIAA botnet|
|infrastructure/fastflux|things used with fastfluxing botnets|

## FQDN ##
|**type**|**description**|
|:-------|:--------------|
|domain/botnet|botnet controllers|
|domain/phishing|things that host phishing|
|domain/malware|things that exploit, drop malware|
|domain/spam|things that host/send spammers|
|domain/spamvertising|things that related to viagra|
|domain/suspicious|things that are unknown but not friendly|
|domain/whitelist|amazon, google, facebook, etc (alexa top 10000ish)|
|domain/fastflux|things used with fastfluxing botnets|

## Email ##
|**type**|**description**|
|:-------|:--------------|
|email/phishing|things that host phishing|
|email/spam|things that host/send spammers|
|email/spamvertising|things that related to viagra|
|email/suspicious|things that are unknown but not friendly|
|email/registrant|used for tracking suspicious email aliases|
|email/whitelist|addresses that need whitelisting from feeds|

## URL ##
|**type**|**description**|
|:-------|:--------------|
|url/botnet|botnet controllers|
|url/phishing|things that host phishing|
|url/malware|things that exploit, drop malware|
|url/spam|things that host/send spammers|
|url/spamvertising|things that related to viagra|
|url/suspicious|things that are unknown but not friendly|
|url/whitelist|urls that need whitelisting|

## Malware ##
|**type**|**description**|
|:-------|:--------------|
|malware/md5|malware md5 hashes|
|malware/sha1|malware sha1 hashes|
|malware/uuid|malware uuid hashes|