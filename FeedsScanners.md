

# Introduction #
The [scanner](TaxonomyImpact#Scanner.md) assessment is typically a [medium severity](TaxonomySeverity#Medium.md) feed depicting known malicious scanners brute-forcing the internet (ssh, portscanners, etc).

Typical examples might include items from:
  * the http://sshbl.org list ([medium](TaxonomyConfidence#41_-_74.md) confidence)
  * the [DRG SSH](http://dragonresearchgroup.org/insight/sshpwauth.txt) list ([medium](TaxonomyConfidence#41_-_74.md) confidence)

# Details #
## Infrastructure ##
### API ###
```
GET https://cif.example.com:443/api/infrastructure/scan?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/scan?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/scan?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/scan -c 95 -s medium
$ cif -q infrastructure/scan -c 85 -s medium
$ cif -q infrastructure/scan -c 40 -s medium
$ cif -q infrastructure/scan -c 95 -s medium -p iptables
$ cif -q infrastructure/scan -c 95 -s medium -p snort
```