# Introduction #

This document defines a pain scale. These values are defined within the context of the object we're attempting to describe.

# High #
  * that this will cause you pain
  * usually an indication of a compromise (if the observation is high-confidence.. 85-100)
  * this could be causing someone else pain (and you're participating), which could cause you pain later
  * examples include botnet infrastructure, DOS attacks, malware samples (the binaries)

# Medium #
  * this might cause you pain
  * there is no legitimate reason to see this traffic, but it might not be indicative of a compromise (by itself)
  * could indicate an exploit attempt (success is unknown)
  * examples include exploit infrastructure, phishing lures, (ssh|rdp|voip) scanners

# Low #
  * supporting data
  * usually machine enumerated data
  * examples include passivedns data, searches, name-servers derived from domain data
  * should only be used to correlate assumptions of other data points

# Null #
  * whitelists
  * could cause you pain if you act on it in-correctly (collateral damage)
  * just because something is in this category; doesn't mean it's 100% good, just means it should factor into your risk equation. Yahoo could be hosting something bad, but it might not be worth acting / blocking on. Your business risk assessments should assess this.