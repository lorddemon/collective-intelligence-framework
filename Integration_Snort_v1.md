# Introduction #

Snort IDS integration is pretty simple.


# Details #

Snort has a built-in plugin leveraging the [Snort::Rule](http://search.cpan.org/~saxjazman/Snort-Rule/) perl module.

```
$ cif -q infrastructure/network -s medium -p snort
alert ip any any -> 2.56.0.0/14 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:1; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL102988; priority:5; )
alert ip any any -> 31.11.43.0/24 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:2; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL113323; priority:5; )
alert ip any any -> 31.222.200.0/21 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:3; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL111681; priority:5; )
alert ip any any -> 41.221.112.0/20 any ( msg:"need-to-know - malicious network hijacked"; threshold:type limit,track by_src,count 1,seconds 3600; sid:4; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL73618; priority:5; )
...
```