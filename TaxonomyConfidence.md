# Introduction #

Confidence details the degree of certainty of a given observation.

# Details #

## Certain (95 - 100) ##
  * highly vetted data by known, trusted security professionals
  * vetting relationship has been consistent for more than 2 years
  * very specific data (eg: ip+port+protocol, or a specific url, or malware hash)

## Very Confident (85 - 94) ##
  * vetted data by known, trusted security professionals
  * data that has been vetted by a human or set of known and proven processes
  * vetting relationship has been consistent and in-place for at-least 1 year
  * data feed has been observed for at-least a year
  * data should be highly specific (eg: port/protocols, prefixes should be as narrow as possible)

## Somewhat Confident (75 - 84) ##
  * semi-vetted data by a security professional or trusted analytics process
  * data that has under-gone **some** either machine or human vetting (eg: checked against a whitelist automatically)

## Not Confident (41 - 74) ##
  * machine generated data or enumerated data
  * some feeds might fall in the category if the author is lazy, or trying to cram too much into the feed
  * examples might include a domains list where the author is simply taking a botnet urls list and posting just the domains as a feed

## Unknown (0 - 39) ##
  * machine generated / enumerated data
  * examples include:
    * auto-enumerated name-servers from domains
    * infrastructure resolved from domain data