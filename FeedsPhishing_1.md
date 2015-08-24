<font color='red'>
<h1>Unstable</h1>
<ul><li>fix api examples<br>
</font></li></ul>



# Introduction #
The [phishing](TaxonomyAssessment_v1#Phishing.md) assessment is typically a feed of indicators that are attempting to phish for credentials on your network.

Typical examples might include items from:
  * the http://www.phishtank.com list ([medium](TaxonomyConfidence_v1#41_-_74.md) confidence)

# Details #
## Infrastructure ##

---

Typically addresses that have been enumerated from phishing domains. Confidence tends to be lower than that of a phishing domain and/or url.

### API ###
```
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/phishing?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/phishing -c 95
$ cif -q infrastructure/phishing -c 85
$ cif -q infrastructure/phishing -c 65
$ cif -q infrastructure/phishing -c 95 -p snort
$ cif -q infrastructure/phishing -c 95 -p iptables
```
## Domains ##

---

Typically addresses that have been enumerated from a phishing url. Confidence tends to be lower than that of a more specific phishing url.
### API ###
```
GET https://cif.example.com:443/api/domain/phishing?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/domain/phishing?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/domain/phishing?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q domain/phishing -c 95
$ cif -q domain/phishing -c 85
$ cif -q domain/phishing -c 65
$ cif -q domain/phishing -c 95 -p snort
$ cif -q domain/phishing -c 95 -p bindzone
```
## Urls ##

---

### API ###
```
GET https://cif.example.com:443/api/url/phishing?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/url/phishing?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/url/phishing?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q url/phishing -c 95
$ cif -q url/phishing -c 85
$ cif -q url/phishing -c 65
$ cif -q url/phishing -c 95 -p csv
$ cif -q url/phishing -c 95 -p snort
```
## Email ##

---

Typically reply-to type drop boxes used in phishing attempts.

### API ###
```
GET https://cif.example.com:443/api/email/phishing?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/email/phishing?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/email/phishing?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q email/phishing -c 95
$ cif -q email/phishing -c 85
$ cif -q email/phishing -c 65
$ cif -q email/phishing -c 95 -p snort
```