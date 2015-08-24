

# Introduction #
The [phishing](TaxonomyImpact#Phishing.md) assessment is typically a [medium severity](TaxonomySeverity#Medium.md) feed depicting things that probably have no business being seen on your network. Communications with these addresses will probably lead to a credential type theft when combined with a [high](TaxonomyConfidence#85_-_94.md) confidence observation.

Typical examples might include items from:
  * the http://www.phishtank.com list ([medium](TaxonomyConfidence#41_-_74.md) confidence)

# Details #
## Infrastructure ##
Typically addresses that have been enumerated from phishing domains. Confidence tends to be lower than that of a phishing domain and/or url.

### API ###
```
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/phishing -c 95 -s medium
$ cif -q infrastructure/phishing -c 85 -s medium
$ cif -q infrastructure/phishing -c 40 -s medium
$ cif -q infrastructure/phishing -c 95 -s medium -p snort
$ cif -q infrastructure/phishing -c 95 -s medium -p iptables
```
## Domains ##
Typically addresses that have been enumerated from a phishing url. Confidence tends to be lower than that of a more specific phishing url.
### API ###
```
GET https://cif.example.com:443/api/domain/phishing?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/domain/phishing?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/domain/phishing?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q domain/phishing -c 95 -s medium
$ cif -q domain/phishing -c 85 -s medium
$ cif -q domain/phishing -c 40 -s medium
$ cif -q domain/phishing -c 95 -s medium -p snort
$ cif -q domain/phishing -c 95 -s medium -p bindzone
```
## Urls ##
### API ###
```
GET https://cif.example.com:443/api/url/phishing?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/url/phishing?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/url/phishing?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q url/phishing -c 95 -s medium
$ cif -q url/phishing -c 85 -s medium
$ cif -q url/phishing -c 40 -s medium
$ cif -q url/phishing -c 95 -s medium -p csv
$ cif -q url/phishing -c 95 -s medium -p snort
```
## Email ##
Typically reply-to type drop boxes used in phishing attempts.

### API ###
```
GET https://cif.example.com:443/api/email/phishing?confidence=95&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/email/phishing?confidence=85&severity=medium&apikey=XXX
GET https://cif.example.com:443/api/email/phishing?confidence=40&severity=medium&apikey=XXX
```

### CLI ###
```
$ cif -q email/phishing -c 95 -s medium
$ cif -q email/phishing -c 85 -s medium
$ cif -q email/phishing -c 40 -s medium
$ cif -q email/phishing -c 95 -s medium -p snort
```