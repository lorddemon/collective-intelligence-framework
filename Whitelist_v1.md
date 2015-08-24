# Whitelisting #

CIFv1 has the capability to whitelist observations from entering a feed during the feed generation process.

### How does whitelisting work in CIFv1? ###

Any observation (IP, domain, URL) with the following will be whitelisted during feed generation:

  * Assessment = whitelist
  * Confidence >= 25

### How does an observation get an assessment of "whitelist" and a confidece >= 25? ###

By default CIFv1 is configured with the following whitelists:

  * https://github.com/collectiveintel/cif-v1/tree/master/cif-smrt/rules/etc/00_alexa_whitelist.cfg
  * https://github.com/collectiveintel/cif-v1/tree/master/cif-smrt/rules/etc/00_mirc_whitelist.cfg
  * https://github.com/collectiveintel/cif-v1/tree/master/cif-smrt/rules/etc/00_whitelist.cfg

Looking at the 00\_whitelist.cfg file you'll see there are additional configuration files that contribute to whitelisting.

When these feeds are processed via cif\_smrt using the '-P' flag, cif\_smrt applies the following logic:

  * resolve all domains to their ip's, slightly degrade the confidence value, whitelist the ip's
  * resolve all ip's to their bgp prefix, slightly degrade the confidence value, whitelist the prefix (/16, /18, /22, /24, etc).

For example:

  1. google.com is given the assessment 'whitelist' with a confidence value of 95%
  1. google.com resolves to: 173.194.46.64-78, which are whitelisted at ~ 69% confidence
  1. 173.194.46.64-78 resolves to 173.194.46.0/24 (bgp prefix lookup)
  1. 173.194.46.0/24 is whitelisted 47% confidence

When a feed is generated, a whitelist data-set is pre-populated with these values and the feed items are checked against them (sub-domains included).