# Introduction to the CIF Server #

A CIF server is a Linux host running Apache, Postgres, and the CIF Server components.

A CIF server has the following primary roles:
  * Parse, normalize and store feeds of threat intelligence
    * Domains, URLs, IP addresses, etc
  * Generates analytics from parsed data
  * Provide query access to the threat intelligence warehouse via:
    * CLI client
    * Browser client
    * API
  * Generate threat feeds from the intelligence warehoused
  * Provide threat feeds via the CLI client
  * Supports tagging of threat intelligence via groups
  * Supports hundreds users via API keys
  * Supports federated data sharing

