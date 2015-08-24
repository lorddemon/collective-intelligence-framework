**DONT TRY THIS AT HOME, USE A SUPPORTED DISTRO**

there are some C-like deps missing from this that we haven't had the resources to flush out.

```
sudo perl -MCPAN -e 'install Class::DBI, XML::LibXML, XML::IODEF, Digest::SHA1, Digest::MD5, Net::CIDR, Net::Abuse::Utils, XML::Malware, Regexp::Common, Regexp::Common::net::CIDR, DateTime, DateTime::Format::DateParse, Unicode::String, Encode, Net::DNS,Class::DBI, Text::Table, Apache2::REST,JSON, Net::DNS, Config::Simple, Pod::POM, IO::Socket::INET6, Linux::Cpuinfo,VT::API, Date::Manip, LWP::Protocol::https,Try::Tiny'
```