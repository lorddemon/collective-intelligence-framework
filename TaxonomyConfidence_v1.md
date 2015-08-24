

# Introduction #

Confidence details the degree of certainty of a given observation. For instance:

  * "I am 85% confident that on 2013-05-05T00:00:01Z example.com is dropping malware"
  * "I am 95% confident that partner-1's observation that `http://example.com/1.html` on 2013-05-05T00:00:01Z was being used as a phishing url"

# Details #

## (95 - 99) Certain ##
  * highly vetted data by known, trusted security professionals
  * vetting relationship has been consistent for more than 2 years
  * very specific data (eg: ip+port+protocol, or a specific url, or malware hash)
  * can typically be used via traffic mitigation processes (null-routing, firewall DROP, etc) with very little risk in collateral damage.

## (85 - 94) Very Confident ##
  * vetted data by known, trusted security professionals
  * data that has been vetted by a human or set of known and proven processes
  * vetting relationship has been consistent and in-place for at-least 1 year
  * data feed has been observed for at-least a year
  * data should be highly specific (eg: port/protocols, prefixes should be as narrow as possible)
  * can typically be used via traffic mitigation processes (null-routing, firewall DROP, etc) with very little risk in collateral damage.

## (75 - 84) Somewhat Confident ##
  * semi-vetted data by a security professional or trusted analytics process
  * data that has under-gone **some** either machine or human vetting (eg: checked against a whitelist automatically)
  * could be leveraged in traffic mitigation processes (eg: dns sink-holing), contains slight risk of collateral damage, but still severely mitigated by native whitelisting process.

## (50 - 74) Not Confident ##
  * searches (50)
  * machine generated data or enumerated data
  * some feeds might fall in the category if the author is lazy, or trying to cram too much into the feed
  * examples might include a domains list where the author is simply taking a botnet urls list and posting just the domains as a feed (65)
  * carries risk when used in automatic mitigation processes

## (00 - 49) Unknown ##
  * machine generated / enumerated data
  * examples include:
    * auto-enumerated name-servers from domains
    * infrastructure resolved from domain data
  * carries significant risk when used in automatic mitigation processes