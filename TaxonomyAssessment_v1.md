# Introduction #

Assessment describes the technical label of a given observation. It is meant to be more descriptive than prescriptive ("what is it?" vs "where does it go?").

# Native Assessments #
There are several native assessment types within the framework. Their rigid nature provide for faster pre-cached feed generation. To add additional assessments, plugins need to be created. Today, there is no template for this, but will be coming soon. If you need help with a particular assessment, please ask the users list. Sometimes it makes sense to add an additional assessment, sometimes it doesn't. This process will improve as the framework evolves.

## Botnet ##
The botnet assessment depicts:

  * typically a host used to control another host or malicious process
  * matching traffic would usually indicate infection
  * typically used to identify compromised hosts

## Malware ##
The malware assessment depicts:

  * typically a host used to exploit and/or drop malware to a host for the first time
  * typically NOT a botnet controller (although they could overlap)
  * communications with these indicators may lead to a compromise and then to a possible botnet controller communication (if the infection was successful).
  * typically used in preemptive blocking, alerts may not indicate infection was successful

Typical examples might include items from:

  * http://www.malwaredomains.com

## Phishing ##
The phishing assessment depicts:

  * a luring attempt at a victim to exfiltrate some sort of credential
  * a targeted attempt at getting someone to unintentionally cause infection (spear phishing)

Typical examples might include items from:

  * http://www.phishtank.com

## Fastflux ##
The fastflux assessment depicts:

  * typically describing a botnet profile where fastflux activity is taking place

## Scanner ##
The scanner assessment depicts:

  * typically infrastructure being used to scan or brute-force (ssh, rdp, telnet, etc...)

Typical examples might include observations from:

  * http://sshbl.org
  * http://dragonresearchgroup.org/insight/sshpwauth.txt

## Spam ##
The spam assessment depicts:

  * typically infrastructure being used to facilitate the sending of spam

## Searches ##
The search assessment depicts:

  * identify's that someone searched for something of possible significance

## Suspicious ##
The suspicious assessment depicts:

  * Unknown assessment
  * used as the "last default" assessment, combined with "description" for more accurate assessment (eg: assessment- suspicious, description- 'hijacked prefix', or assessment- suspicious, description- 'nameserver').

## Whitelist ##
The Whitelist assessment depicts:

  * denotes that specific entity (usually an address) should be considered harmless in nature
  * denotes that blocking an entity would result in mass collateral damage (eg: yahoo virtually hosted services)
  * confidence should be applied to each entry to help calculate risk associated with whitelist