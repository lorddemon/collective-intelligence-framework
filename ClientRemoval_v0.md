**Table of Contents**


# Preamble #

---

This doc shows how to manually remove the legacy v0 perl based client. This does NOT apply to the browser plugins which can be upgraded by simply installing the newest version of the plugin.

This doc assumes the 'CIF::Client' was installed via CPAN. If it was installed manually, the removal procedure should be the same, although in some cases the paths might be different.

# Removal #
  1. remove the /usr/local/bin/cif command utility
  1. The CIF client library is installed as a 'local' perl module, therefor most if it's files should be somewhere in /usr/local/share/perl/5.10.X/CIF... (or similar).
  1. find all the CIF related files
```
$ find /usr/local | grep CIF
...
/usr/local/share/perl/5.10.1/CIF
/usr/local/share/perl/5.10.1/CIF/Client.pm
/usr/local/share/perl/5.10.1/CIF/Client
/usr/local/share/perl/5.10.1/CIF/Client/Plugin
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iptables.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Csv.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Table.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Parser.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Pcapfilter.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Bindzone.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Malware.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Ipv4.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Bgp.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Url.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Group.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef/Domain.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Raw.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Output.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Iodef.pm
/usr/local/share/perl/5.10.1/CIF/Client/Plugin/Snort.pm
/usr/local/share/man/man3/CIF::Client.3pm
/usr/local/lib/perl/5.10.1/auto/CIF
/usr/local/lib/perl/5.10.1/auto/CIF/Client
/usr/local/lib/perl/5.10.1/auto/CIF/Client/.packlist
```
  1. this list should ONLY show CIF related modules that have been installed, to remove, simply remove the top level CIF directory:
```
$ sudo rm -R -f /usr/local/share/perl/5.10.1/CIF
```
  1. re-run the find command and clear out any remaining CIF files:
```
$ find /usr/local | grep CIF
...
/usr/local/share/man/man3/CIF::Client.3pm
/usr/local/lib/perl/5.10.1/auto/CIF
/usr/local/lib/perl/5.10.1/auto/CIF/Client
/usr/local/lib/perl/5.10.1/auto/CIF/Client/.packlist
```