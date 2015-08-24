

# Suspicious Networks #
## Table Format ##
  1. CIDR query
```
$ cif -q 130.201.0.0/16
Query: 130.201.0.0/16
Feed Restriction: private
Feed Created: 2011-01-21T14:25:58Z

restriction |severity|address|portlist|detecttime|description|alternativeid_restriction|alternativeid                                        
need-to-know|high    |130.201.0.0/16|        |2011-01-20 00:00:00+00|hijacked network infrastructure 130.201.0.0/16|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
need-to-know|high    |130.201.0.0/16|        |2011-01-21 00:00:00+00|hijacked network infrastructure 130.201.0.0/16|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
```
  1. ipv4-addr query
```
$ cif -q 130.201.0.1
Query: 130.201.0.1
Feed Restriction: private
Feed Created: 2011-01-21T14:26:51Z

restriction |severity|address       |portlist|detecttime            |description                                   |alternativeid_restriction|alternativeid                                        
need-to-know|high    |130.201.0.0/16|        |2011-01-20 00:00:00+00|hijacked network infrastructure 130.201.0.0/16|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
need-to-know|high    |130.201.0.0/16|        |2011-01-21 00:00:00+00|hijacked network infrastructure 130.201.0.0/16|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
private     |        |130.201.0.0/16|        |2011-01-21 14:00:00+00|search 130.201.0.0/16                         |private                  |                                     
```
  1. suspicious network feed (high severity)
```
$ cif -q infrastructure/network

restriction |severity|address         |portlist|detecttime            |description                                     |alternativeid_restriction|alternativeid                                        
need-to-know|high    |130.201.0.0/16  |        |2011-01-20 00:00:00+00|hijacked network infrastructure 130.201.0.0/16  |public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200
need-to-know|high    |188.229.13.0/24 |        |2011-01-20 00:00:00+00|hijacked network infrastructure 188.229.13.0/24 |public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL89529 
need-to-know|high    |204.28.104.0/21 |        |2011-01-20 00:00:00+00|hijacked network infrastructure 204.28.104.0/21 |public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL96986 
need-to-know|high    |200.106.128.0/20|        |2011-01-20 00:00:00+00|hijacked network infrastructure 200.106.128.0/20|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL85870 
need-to-know|high    |195.234.159.0/24|        |2011-01-20 00:00:00+00|hijacked network infrastructure 195.234.159.0/24|public                   |http://www.spamhaus.org/sbl/sbl.lasso?query=SBL57950 
```
## Snort Format ##
```
$ cif -q infrastructure/network -p snort

alert ip any any -> 130.201.0.0/16 any ( msg:"need-to-know - hijacked network infrastructure 130.201.0.0/16"; threshold:type limit,track by_src,count 1,seconds 3600; sid; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200; )
alert ip any any -> 188.229.13.0/24 any ( msg:"need-to-know - hijacked network infrastructure 188.229.13.0/24"; threshold:type limit,track by_src,count 1,seconds 3600; sid:1; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL89529; )
alert ip any any -> 204.28.104.0/21 any ( msg:"need-to-know - hijacked network infrastructure 204.28.104.0/21"; threshold:type limit,track by_src,count 1,seconds 3600; sid:2; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL96986; )
alert ip any any -> 200.106.128.0/20 any ( msg:"need-to-know - hijacked network infrastructure 200.106.128.0/20"; threshold:type limit,track by_src,count 1,seconds 3600; sid:3; reference:http://www.spamhaus.org/sbl/sbl.lasso?query=SBL8587
```
## CSV  Format ##
```
$ cif -q infrastructure/network -p csv
# address,alternativeid,alternativeid_restriction,asn,asn_desc,cc,cidr,confidence,created,description,detecttime,impact,message,portlist,protocol,restriction,rir,severity,uuid
130.201.0.0/16,http://www.spamhaus.org/sbl/sbl.lasso?query=SBL101200,LIMITED,23504,SPEAKEASY Speakeasy, Inc.,,128.0.0.0/2,9,2011-04-14 00:15:08.560785+00,hijacked network infrastructure 130.201.0.0/16,2011-04-14 00:00:00+00,hijacked network infrastructure,,,,PRIVILEGED,,high,ae7a011a-c6c3-5f2f-a960-5c703bc7b7db
188.229.13.0/24,http://www.spamhaus.org/sbl/sbl.lasso?query=SBL89529,LIMITED,23504,SPEAKEASY Speakeasy, Inc.,,128.0.0.0/2,9,2011-04-14 00:15:14.53268+00,hijacked network infrastructure 188.229.13.0/24,2011-04-14 00:00:00+00,hijacked network infrastructure,,,,PRIVILEGED,,high,53e5ec11-2b95-5d05-9c44-a65cae5ac414
204.28.104.0/21,http://www.spamhaus.org/sbl/sbl.lasso?query=SBL96986,LIMITED,23504,SPEAKEASY Speakeasy, Inc.,,192.0.0.0/3,9,2011-04-14 00:15:34.525974+00,hijacked network infrastructure 204.28.104.0/21,2011-04-14 00:00:00+00,hijacked network infrastructure,,,,PRIVILEGED,,high,801d0d74-5564-5a2a-bc3f-bb1296faf506
200.106.128.0/20,http://www.spamhaus.org/sbl/sbl.lasso?query=SBL85870,LIMITED,21560,NETSTREAM-COMMUNICATIONS Netstream Communications, LLC,CO,200.106.128.0/21,9,2011-04-14 00:15:31.856361+00,hijacked network infrastructure 200.106.128.0/20,2011-04-14 00:00:00+00,hijacked network infrastructure,,,,PRIVILEGED,lacnic,high,a333fc42-f0cf-5f6d-a691-c66e3de76899
```
# Scanners #
## Table  Format ##
```
$ cif -q infrastructure/scan -s medium

restriction |severity|address        |portlist|detecttime            |description                |alternativeid_restriction|alternativeid                      
need-to-know|medium  |124.162.54.219 |22      |2010-12-23 04:04:00+00|ssh scanner 124.162.54.219 |public                   |http://www.sshbl.org/lists/date.txt
need-to-know|medium  |85.25.144.108  |22      |2010-12-23 08:55:53+00|ssh scanner 85.25.144.108  |public                   |http://www.sshbl.org/lists/date.txt
need-to-know|medium  |88.191.130.49  |22      |2010-12-23 11:09:51+00|ssh scanner 88.191.130.49  |public                   |http://www.sshbl.org/lists/date.txt
need-to-know|medium  |58.180.49.43   |22      |2010-12-23 12:02:56+00|ssh scanner 58.180.49.43   |public                   |http://www.sshbl.org/lists/date.txt
```
## IPTABLES  Format ##
```
$ cif -q infrastructure/scan -p iptables -s medium
iptables -N CIF_IN
iptables -F CIF_IN
iptables -N CIF_OUT
iptables -F CIF_OUT
iptables -A CIF_IN -s 124.162.54.219 -j DROP
iptables -A CIF_OUT -d 124.162.54.219 -j DROP
iptables -A CIF_IN -s 85.25.144.108 -j DROP
iptables -A CIF_OUT -d 85.25.144.108 -j DROP
iptables -A CIF_IN -s 88.191.130.49 -j DROP
iptables -A CIF_OUT -d 88.191.130.49 -j DROP
```

# Malware/Exploit Infrastructure #
## Table  Format ##
```
$ cif -q infrastructure/malware -s low

restriction |severity|address        |portlist|detecttime            |description                                                                                |alternativeid_restriction|alternativeid                                                                       
need-to-know|low     |114.207.244.145|        |2011-01-20 17:38:11+00|malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.145                      |public                   |http://www.malwaredomains.com/files/domains.txt                                     
need-to-know|low     |114.207.244.144|        |2011-01-20 17:38:11+00|malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.144                      |public                   |http://www.malwaredomains.com/files/domains.txt                                     
need-to-know|low     |114.207.244.146|        |2011-01-20 17:38:11+00|malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.146                      |public                   |http://www.malwaredomains.com/files/domains.txt                                     
need-to-know|low     |114.207.244.143|        |2011-01-20 17:38:12+00|malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.143                      |public                   |http://www.malwaredomains.com/files/domains.txt   
```
## Snort  Format ##
```
$ cif -q infrastructure/malware -s low -p snort

alert ip any any -> 114.207.244.145 any ( msg:"need-to-know - malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.145"; threshold:type limit,track by_src,count 1,seconds 3600; sid; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 114.207.244.144 any ( msg:"need-to-know - malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.144"; threshold:type limit,track by_src,count 1,seconds 3600; sid:1; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 114.207.244.146 any ( msg:"need-to-know - malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.146"; threshold:type limit,track by_src,count 1,seconds 3600; sid:2; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 114.207.244.143 any ( msg:"need-to-know - malicious infrastructure rogue abodeflash-vol44.co.cc 114.207.244.143"; threshold:type limit,track by_src,count 1,seconds 3600; sid:3; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 174.36.71.44 any ( msg:"need-to-know - malicious infrastructure harmful adplus.in 174.36.71.44"; threshold:type limit,track by_src,count 1,seconds 3600; sid:4; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 205.209.184.136 any ( msg:"need-to-know - malicious infrastructure unknown bellmorefinancial.com 205.209.184.136"; threshold:type limit,track by_src,count 1,seconds 3600; sid:5; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 61.191.55.37 any ( msg:"need-to-know - malicious infrastructure unknown bidz.cn 61.191.55.37"; threshold:type limit,track by_src,count 1,seconds 3600; sid:6; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 65.254.60.240 any ( msg:"need-to-know - malicious infrastructure malvertising blerin.com 65.254.60.240"; threshold:type limit,track by_src,count 1,seconds 3600; sid:7; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 68.67.68.10 any ( msg:"need-to-know - malicious infrastructure harmful bluelinefreight.in 68.67.68.10"; threshold:type limit,track by_src,count 1,seconds 3600; sid:8; reference:http://www.malwaredomains.com/files/domains.txt; )
alert ip any any -> 210.114.175.151 any ( msg:"need-to-know - malicious infrastructure harmful bumin.org 210.114.175.151"; threshold:type limit,track by_src,count 1,seconds 3600; sid:9; reference:http://www.malwaredomains.com/files/domain.txt; )
```
# Phishing Infrastructure #
## Table  Format ##
```
$ cif -q infrastructure/phishing -s low

restriction|severity|address        |protocol|portlist|detecttime            |impact                 |description                                                                     |alternativeid_restriction|alternativeid                                             
need-to-know    |low     |190.123.46.115 |        |        |2011-01-13 17:25:12+00|phishing infrastructure|phishing infrastructure target:Other 190.123.46.115                             |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101217
need-to-know    |low     |83.64.29.203   |        |        |2011-01-13 17:30:56+00|phishing infrastructure|phishing infrastructure target:PayPal 83.64.29.203                              |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101221
need-to-know    |low     |67.221.186.208 |        |        |2011-01-13 17:51:05+00|phishing infrastructure|phishing infrastructure target:Amazon.com 67.221.186.208                        |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101223
need-to-know    |low     |64.62.181.46   |        |        |2011-01-13 18:01:33+00|phishing infrastructure|phishing infrastructure target:Facebook 64.62.181.46                            |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101243
need-to-know    |low     |216.52.115.2   |        |        |2011-01-13 18:02:46+00|phishing infrastructure|phishing infrastructure target:Facebook 216.52.115.2                            |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101246
```
## Snort  Format ##
```
$ cif -q infrastructure/phishing -s low -p snort

alert ip any any -> 190.123.46.115 any ( msg:"need-to-know - phishing infrastructure target:Other 190.123.46.115"; threshold:type limit,track by_src,count 1,seconds 3600; sid; reference:http://www.phishtank.com/phish_detail.php?phish_id=1101217; )
alert ip any any -> 83.64.29.203 any ( msg:"need-to-know - phishing infrastructure target:PayPal 83.64.29.203"; threshold:type limit,track by_src,count 1,seconds 3600; sid:1; reference:http://www.phishtank.com/phish_detail.php?phish_id=1101221; )
alert ip any any -> 67.221.186.208 any ( msg:"need-to-know - phishing infrastructure target:Amazon.com 67.221.186.208"; threshold:type limit,track by_src,count 1,seconds 3600; sid:2; reference:http://www.phishtank.com/phish_detail.php?phish_id=1101223; )
alert ip any any -> 64.62.181.46 any ( msg:"need-to-know - phishing infrastructure target:Facebook 64.62.181.46"; threshold:type limit,track by_src,count 1,seconds 3600; sid:3; reference:http://www.phishtank.com/phish_detail.php?phish_id=1101243; )
```

# Suspicious Nameservers #
## Table  Format ##
```
$> cif -q domain/nameserver -s low

restriction |severity|address                                    |rdata          |type|detecttime            |description                                                                          |alternativeid_restriction|alternativeid                                                                    
need-to-know|low     |ns1.tophostingcenter.com                   |67.228.41.55   |A   |2011-01-20 17:38:23+00|suspicious nameserver malicious domain harmful adplus.in                             |public                   |http://www.malwaredomains.com/files/domains.txt                                  
need-to-know|low     |ns2.tophostingcenter.com                   |74.86.129.68   |A   |2011-01-20 17:38:24+00|suspicious nameserver malicious domain harmful adplus.in                             |public                   |http://www.malwaredomains.com/files/domains.txt                                  
need-to-know|low     |ns1.reg.ru                                 |217.16.28.64   |A   |2011-01-20 17:38:27+00|suspicious nameserver malicious domain unknown banderboss.ru                         |public                   |http://www.malwaredomains.com/files/domains.txt                                  
need-to-know|low     |ns2.reg.ru                                 |178.218.208.130|A   |2011-01-20 17:38:28+00|suspicious nameserver malicious domain unknown banderboss.ru                         |public                   |http://www.malwaredomains.com/files/domains.txt                                  
```
```
Query: tophostingcenter.com
Feed Restriction: RESTRICTED
Feed Created: 2011-05-12T13:07:02Z

restriction|severity|address                 |rdata        |type|detecttime            |impact                                    |description                                                       |alternativeid_restriction|alternativeid                                  
PRIVILEGED |low     |ns1.tophostingcenter.com|67.228.41.55 |A   |2011-01-18 17:42:08+00|suspicious nameserver adplus.in           |suspicious nameserver malicious domain harmful adplus.in          |LIMITED                  |http://www.malwaredomains.com/files/domains.txt
PRIVILEGED |low     |ns2.tophostingcenter.com|74.86.129.68 |A   |2011-01-26 15:31:27+00|suspicious nameserver adplus.in           |suspicious nameserver malicious domain harmful adplus.in          |LIMITED                  |http://www.malwaredomains.com/files/domains.txt
PRIVILEGED |low     |ns1.tophostingcenter.com|67.228.41.55 |A   |2011-01-26 15:31:27+00|suspicious nameserver adplus.in           |suspicious nameserver malicious domain harmful adplus.in          |LIMITED                  |http://www.malwaredomains.com/files/domains.txt
PRIVILEGED |low     |ns1.tophostingcenter.com|67.228.41.55 |A   |2011-01-26 19:02:13+00|suspicious nameserver adplus.in           |suspicious nameserver malicious domain harmful adplus.in adplus.in|LIMITED                  |http://www.malwaredomains.com/files/domains.txt
PRIVILEGED |low     |ns2.tophostingcenter.com|74.86.129.68 |A   |2011-01-26 19:02:14+00|suspicious nameserver adplus.in           |suspicious nameserver malicious domain harmful adplus.in adplus.in|LIMITED                  |http://www.malwaredomains.com/files/domains.txt
RESTRICTED |low     |ns4.tophostingcenter.com|208.43.34.231|A   |2011-02-15 10:28:44+00|suspicious nameserver siteihosting.com    |suspicious nameserver malware domain siteihosting.com             |RESTRICTED               |                                               
RESTRICTED |low     |ns5.tophostingcenter.com|208.43.34.232|A   |2011-02-15 10:28:45+00|suspicious nameserver siteihosting.com    |suspicious nameserver malware domain siteihosting.com             |RESTRICTED               |                                               
                                         
RESTRICTED |low     |ns5.tophostingcenter.com|208.43.34.232|A   |2011-02-15 21:25:27+00|suspicious nameserver siteihosting.com    |suspicious nameserver malware domain siteihosting.com             |RESTRICTED               |                                               
RESTRICTED |low     |ns4.tophostingcenter.com|208.43.34.231|A   |2011-02-16 04:25:22+00|suspicious nameserver siteihosting.com    |suspicious nameserver malware domain siteihosting.com             |RESTRICTED               |                                               
RESTRICTED |low     |ns5.tophostingcenter.com|208.43.34.232|A   |2011-02-16 04:25:22+00|suspicious nameserver siteihosting.com    |suspicious nameserver malware domain siteihosting.com             |RESTRICTED               |                                               
RESTRICTED |low     |ns5.tophostingcenter.com|208.43.34.232|A   |2011-02-16 08:24:50+00|suspicious nameserver servidoronline.co.cc|suspicious nameserver malware domain servidoronline.co.cc         |RESTRICTED               |                                               
RESTRICTED |low     |ns4.tophostingcenter.com|208.43.34.231|A   |2011-02-16 08:24:50+00|suspicious nameserver servidoronline.co.cc|suspicious nameserver malware domain servidoronline.co.cc         |RESTRICTED               |                                               
RESTRICTED |low     |ns5.tophostingcenter.com|208.43.34.232|A   |2011-02-16 09:24:23+00|suspicious nameserver servidoronline.co.cc|suspicious nameserver malware domain servidoronline.co.cc         |RESTRICTED               |                                               
```
## Bindzone Format ##
```
$ cif -q domain/nameserver -s low -p bindzone

; generated by: /usr/local/bin/cif at 1295613827
zone "ns1.tophostingcenter.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "ns2.tophostingcenter.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "ns1.reg.ru" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "ns2.reg.ru" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "dns3.registrar-servers.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "dns2.registrar-servers.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "dns4.registrar-servers.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "dns1.registrar-servers.com" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
zone "ns2.ndns.cn" {type master; file "/etc/namedb/cif_blockeddomain.hosts";};
```

# Malware/Exploit Urls #
## Table Format ##
```

$ cif -q url/malware -s medium

restriction |severity|address                                                                                                                                                                 |portlist|detecttime            |description                                                    |alternativeid_restriction|alternativeid                                                                       
need-to-know|medium  |http://derts3563d.net/old_files/root/bin/config.bin                                                                                                                     |        |2010-12-25 00:00:00+00|malware url spyeye config md5:15f587e0c9472c7538dff178ea07ee5f |public                   |https://spyeyetracker.abuse.ch/monitor.php?host=derts3563d.net                      
need-to-know|medium  |http://holycrosshrco.org/img_49jfdnmgudfg.jpg                                                                                                                           |        |2010-12-31 00:00:00+00|malware url zeus binary md5:36acc426ab7328c3979c05b9d3743594   |public                   |https://zeustracker.abuse.ch/monitor.php?host=holycrosshrco.org                     
need-to-know|medium  |http://yyyaanve.ru/b.bin                                                                                                                                                |        |2011-01-04 00:00:00+00|malware url zeus config v2 md5:0052e23360b505e45e099355287ad0a5|public                   |https://zeustracker.abuse.ch/monitor.php?host=yyyaanve.ru                           
need-to-know|medium  |http://454ht5h59.com/l.7z                                                                                                                                               |        |2011-01-05 00:00:00+00|malware url zeus config v2 md5:e997f4e34c2f61fe91c9c3e32c56f33c|public                   |https://zeustracker.abuse.ch/monitor.php?host=454ht5h59.com                         
```

# Phishing Urls #
## Table Format ##
```
$ cif -q url/phishing -s low

restriction|severity|address|url_md5                         |url_sha1                                |malware_md5|malware_sha1|detecttime            |impact      |description                                                                                |alternativeid_restriction|alternativeid                                             
need-to-know |medium  |http://us.worldofwarcraft.accountadmin-service.net/customersupport.htm|4f566ced52f11c4e44ab5e16ff6c1e83|a62e153af62552215eb859cdca8c1c6da871948e|           |            |2011-01-13 17:25:12+00|phishing url|phishing url target:Other md5:4f566ced52f11c4e44ab5e16ff6c1e83                             |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101217
need-to-know |medium  |http://www.toyoida.org/components/com_hotornot2/phpthumb/cache/index.html|dcb967c05b2b22c38d6379392b89830e|3226551520c3051c81f98ff68a05dadc43e47604|           |            |2011-01-13 17:30:56+00|phishing url|phishing url target:PayPal md5:dcb967c05b2b22c38d6379392b89830e                            |need-to-know                  |http://www.phishtank.com/phish_detail.php?phish_id=1101221
need-to-know |medium  |http://sport-ro.limewebs.com/amz/processing.php|05db9301b3b5d504570e3bff47e00d39|7d7dd147feaaba43fdbf576b1f6a81a05c168d68|           |            |2011-01-13 17:51:05+00|phishing url|phishing url target:Amazon.com md5:05db9301b3b5d504570e3bff47e00d39 
```

# Malware #
## Table Format ##
```
$ cif -q malware -s medium

restriction|asn|asn_desc|cidr|address|hash_md5                        |hash_sha1                               |description                                                                                                                          |severity|detecttime            |created                      |alternativeid_restriction|alternativeid                                                                                                  
need-to-know |   |        |    |       |0c27b16b999a6656bb39a297cccb38af|840a89fc018ae07ae771da2b0204375644b3fe48|malware binary Virus.Win32.Virut.a                                                                                                   |medium  |2011-03-08 00:00:00+00|2011-03-08 00:28:54.045894+00|LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=VmlydXMuV2luMzIuVmlydXQuYQ==                                        
need-to-know |   |        |    |       |18a5bc3997771d2bcd9935b8bea1fefc|312876bce93f8f424ffafe876c2eda8e512b69f9|malware binary :Spyware.Relevantknowledge.A                                                                                          |medium  |2011-03-08 00:00:00+00|2011-03-08 00:22:10.386712+00|LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=OlNweXdhcmUuUmVsZXZhbnRrbm93bGVkZ2UuQQ==                            
need-to-know |   |        |    |       |3ed38d1e353087a9b0fea7aadb88655c|eb47983cd2a50bacafcd8dcb54677a2496c99121|malware binary Trojan-Downloader.Win32.Agent.dbff                                                                                    |medium  |2011-03-08 00:00:00+00|2011-03-08 00:25:07.978252+00|LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=VHJvamFuLURvd25sb2FkZXIuV2luMzIuQWdlbnQuZGJmZg==  
```
```
$ cif -q malware -s low

restriction |severity|hash_md5                        |hash_sha1                               |detecttime            |description                                                                                         |alternativeid_restriction|alternativeid                                                                                          
need-to-know|medium  |c567c89f3d535c6b0f6cfcd1a648b8f9|                                        |2010-12-24 00:00:00+00|malware spyeye config md5:c567c89f3d535c6b0f6cfcd1a648b8f9                                          |public                   |https://spyeyetracker.abuse.ch/monitor.php?hash=c567c89f3d535c6b0f6cfcd1a648b8f9                       
need-to-know|medium  |815c3dd120ca6b6303c5f657d1971b33|                                        |2010-12-24 00:00:00+00|malware spyeye binary md5:815c3dd120ca6b6303c5f657d1971b33                                          |public                   |https://spyeyetracker.abuse.ch/monitor.php?hash=815c3dd120ca6b6303c5f657d1971b33                       
need-to-know|medium  |c98aa1796a242491d9a85e0c9bd62ff7|                                        |2010-12-24 00:00:00+00|malware spyeye binary md5:c98aa1796a242491d9a85e0c9bd62ff7                                          |public                   |https://spyeyetracker.abuse.ch/monitor.php?hash=c98aa1796a242491d9a85e0c9bd62ff7                       
need-to-know|medium  |fad8d43455309cd60fb04b18845a8119|                                        |2010-12-24 00:00:00+00|malware spyeye config md5:fad8d43455309cd60fb04b18845a8119                                          |public                   |https://spyeyetracker.abuse.ch/monitor.php?hash=fad8d43455309cd60fb04b18845a8119                       
```
```
$ cif -q malware -s medium
Query: malware
Feed Id: 50bbaf57-9dbe-5495-a96f-e3837b6f95f9
Feed Severity: medium
Feed Restriction: PRIVILEGED
Feed Created: 2011-04-05T21:13:34Z

restriction|severity|hash_md5                        |hash_sha1                               |detecttime            |impact               |description                                                                                         |alternativeid_restriction|alternativeid                                                                                                  
PRIVILEGED |medium  |0c27b16b999a6656bb39a297cccb38af|840a89fc018ae07ae771da2b0204375644b3fe48|2011-03-08 00:00:00+00|malware binary       |malware binary Virus.Win32.Virut.a                                                                  |LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=VmlydXMuV2luMzIuVmlydXQuYQ==                                        
PRIVILEGED |medium  |18a5bc3997771d2bcd9935b8bea1fefc|312876bce93f8f424ffafe876c2eda8e512b69f9|2011-03-08 00:00:00+00|malware binary       |malware binary :Spyware.Relevantknowledge.A                                                         |LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=OlNweXdhcmUuUmVsZXZhbnRrbm93bGVkZ2UuQQ==                                                                  
PRIVILEGED |medium  |9a0264353510711abb4e94772d24d020|19ae829f38c1c348dc766d6fc1ff33837245ebfd|2011-03-08 00:00:00+00|malware binary       |malware binary Adware.Generic.148898                                                                |LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=QWR3YXJlLkdlbmVyaWMuMTQ4ODk4                                        
PRIVILEGED |medium  |e91fffed95290a75565444eecf7f5b09|0af0bf1f5b05442601bbd7220c25dfe300cbed68|2011-03-08 00:00:00+00|malware binary       |malware binary W32/VB-Downloader-Minimi-based!Maximus                                               |LIMITED                  |http://www.malware.com.br/cgi/search.pl?id=VzMyL1ZCLURvd25sb2FkZXItTWluaW1pLWJhc2VkIU1heGltdXM=       
PRIVILEGED |medium  |65ca127bcde4b35c3e2994aa2bbbf569|                                        |2011-03-08 00:00:00+00|malware url          |malware url md5:65ca127bcde4b35c3e2994aa2bbbf569                                                    |LIMITED                  |http://malc0de.com/database/index.php?search=65ca127bcde4b35c3e2994aa2bbbf569&MD5=on                           
PRIVILEGED |medium  |0d5d4beda220a754b13cbc5ecea0264d|                                        |2011-03-08 00:00:00+00|malware binary       |malware binary md5:0d5d4beda220a754b13cbc5ecea0264d Downloader.Generic, Downloader, Generic.ff, Troj|LIMITED                  |http://www.threatexpert.com/report.aspx?md5=0d5d4beda220a754b13cbc5ecea0264d         
```

```
$ cif 0d5d4beda220a754b13cbc5ecea0264d  
Query: 0d5d4beda220a754b13cbc5ecea0264d
Feed Restriction: RESTRICTED
Feed Created: 2011-05-09T23:18:58Z

restriction|severity|hash_md5                        |hash_sha1|detecttime            |impact        |description                                                                                         |alternativeid_restriction|alternativeid                                                               
PRIVILEGED |medium  |0d5d4beda220a754b13cbc5ecea0264d|         |2011-03-08 00:00:00+00|malware binary|malware binary md5:0d5d4beda220a754b13cbc5ecea0264d Downloader.Generic, Downloader, Generic.ff, Troj|LIMITED                  |http://www.threatexpert.com/report.aspx?md5=0d5d4beda220a754b13cbc5ecea0264d
```