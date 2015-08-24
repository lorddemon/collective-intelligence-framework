# Introduction #

<font color='red'>UNDER CONSTRUCTION</font>

# Details #

```
The soon to be released Bro 2.2 comes with a new Intelligence Framework. This framework allows Bro to raise a notice when a intelligence item is detected. Once the notice is raised, actions can be taken based on the type of intel, the source, where/how the data was found, etc. The types of intel items currently supported are:

* Single IP
* IP range
* URL
* User-Agent
* E-mail address
* DNS domain name
* Username
* File hash
* Certificate hash

Bro will look for these intelligence items in all the locations one might expect to find them - e.g. DNS domain names can be detected in DNS queries, HTTP host headers, or via the Server Name Indication extension of SSL. The list of locations that get inspected is currently nowhere near complete, and will grow over time.

Also included in this update is a script to better support CIF data - adding fields such as confidence level, impact and severity to the intelligence items. I've created an experimental output plugin for CIF[1] to format the data in the proper format.

To test this out, you will need to use Git to download the latest version of Bro[2]. Any recent version of the CIF client includes the Bro output plugin. To create and update intel files from SES, I recommend using the helper scripts that Keith Lehigh has made available[3].

To enable the intel framework, add something like this to local.bro:

@load policy/frameworks/intel
@load policy/integration/collective-intel

redef Intel::read_files += { "/home/bro/intel/cif_botnet_domains.intel" };

There are a couple of things to keep in mind: 
- Currently, the only way to remove an intelligence item is to remove it from the file, and to restart Bro.
- Bro continuously monitors the intel file(s), and will add new intel items within a few seconds of any changes.
- Bro keeps the file open via file descriptor - you should modify the file in-place, or just use Keith's scripts which take care to do this.

That's about it. Let me know what you think, if you have any questions, or if you'd like some more in-depth instructions on how to get this up and running.

also thanks to mr keith lehigh (@iu):

https://github.com/klehigh/cif2bro-helpers
```