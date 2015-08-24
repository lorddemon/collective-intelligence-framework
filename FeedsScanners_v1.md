<font color='red'>
<h1>Unstable</h1>
<ul><li>fix api examples<br>
</font></li></ul>



# Introduction #
The [scanner](TaxonomyAssessment_v1#Scanner.md) assessment is typically a feed depicting known malicious scanners brute-forcing the internet (ssh, portscanners, etc).

Typical examples might include items from:
  * the http://sshbl.org list ([medium](TaxonomyConfidence_v1#41_-_74.md) confidence)
  * the [DRG SSH](http://dragonresearchgroup.org/insight/sshpwauth.txt) list ([medium](TaxonomyConfidence_v1#41_-_74.md) confidence)

# Details #
## Infrastructure ##

---

### API ###
```
GET https://cif.example.com:443/api/infrastructure/scan?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/scan?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/scan?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/scan -c 95
$ cif -q infrastructure/scan -c 85
$ cif -q infrastructure/scan -c 65
$ cif -q infrastructure/scan -c 95 -p iptables
$ cif -q infrastructure/scan -c 95 -p snort
```