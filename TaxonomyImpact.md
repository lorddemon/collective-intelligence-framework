# Introduction #

See the official [IODEF](http://tools.ietf.org/html/rfc5070#section-3.10.1) Impact class description.

# Details #
## Botnet ##
  * typically a host used to control another host or malicious process
  * matching traffic would usually indicate infection
  * typically used to identify compromised hosts
  * typically [high severity](TaxonomySeverity#High.md) in nature

## Malware / Exploit ##
  * typically a host used to exploit and/or drop malware to a host for the first time
  * not a botnet C&C
  * typically used in preemptive blocking, alerts may not indicate infection was successful
  * typically [medium severity](TaxonomySeverity#Medium.md) in nature

## Phishing ##
  * a luring attempt at a victim to exfiltrate some sort of credential
  * a targeted attempt at getting someone to unintentionally cause infection (spear phishing)
  * typically [medium severity](TaxonomySeverity#Medium.md) in nature

## Networks ##
  * typically a rogue, hijacked, bullet-proof or known criminal network
  * typically [medium severity](TaxonomySeverity#Medium.md) in nature

## Nameserver ##
  * typically a rogue or criminally negligent name-server
  * typically [medium severity](TaxonomySeverity#Medium.md) in nature
  * depicts a name-server where blocking direct access to the server should mitigate future compromises

## Fastflux ##
  * typically describing a botnet profile
  * typically [high severity](TaxonomySeverity#High.md) in nature

## Scanner ##
  * typically infrastructure being used to scan or brute-force (ssh, rdp, telnet, etc...)

## Spam ##
  * typically infrastructure being used to facilitate the sending of spam

## Searches ##
  * identify's that someone searched for something of possible significance
  * typically [low severity](TaxonomySeverity#Low.md) in nature

## Whitelist ##
  * denotes that specific entity (usually an address) should be considered harmless in nature
  * denotes that blocking an entity would result in mass collateral damage (eg: yahoo virtually hosted services)
  * confidence should be applied to each entry to help calculate risk associated with whitelist
  * [Null severity](TaxonomySeverity#Null.md) in nature