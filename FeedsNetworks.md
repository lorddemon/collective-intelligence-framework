

# Introduction #
The [suspicious network](TaxonomyImpact#Networks.md) assessment is typically a [medium severity](TaxonomySeverity#Medium.md) feed depicting things that probably have no business being seen on your network. Communications with these addresses will probably lead to a credential type theft, or compromise when combined with a [high](TaxonomyConfidence#85_-_94.md) confidence observation.

Typical examples might include items from:
  * the [Spamhaus DROP](http://www.spamhaus.org/drop/) list ([high](TaxonomyConfidence#95_-_100.md) confidence)

# Details #
## Infrastructure ##
### API ###
```
GET https://cif.example.com:443/api/infrastructure/network?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/network?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/network?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/network -c 95 -s medium
$ cif -q infrastructure/network -c 85 -s medium
$ cif -q infrastructure/network -c 40 -s medium
```
# Operational Examples #
  * generating a snort rules data-set:
```
$ cif -q infrastructure/network -c 95 -s medium -p snort
```
  * generating an iptables data-set:
```
$ cif -q infrastructure/network -c 95 -s medium -p iptables
```