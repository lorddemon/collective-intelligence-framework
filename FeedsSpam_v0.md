

# Introduction #
The [spam](TaxonomyImpact_v0#Spam.md) assessment is typically a [medium severity](TaxonomySeverity_v0#Medium.md) feed depicting known malicious spam infrastructure.

# Details #
## Infrastructure ##
### API ###
```
GET https://cif.example.com:443/api/infrastructure/spam?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/spam?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/spam?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/spam -c 95 -s medium
$ cif -q infrastructure/spam -c 85 -s medium
$ cif -q infrastructure/spam -c 40 -s medium
$ cif -q infrastructure/spam -c 95 -s medium -p iptables
$ cif -q infrastructure/spam -c 95 -s medium -p snort
```