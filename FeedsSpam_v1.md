<font color='red'>
<h1>Unstable</h1>
<ul><li>fix api examples<br>
</font></li></ul>



# Introduction #
The [spam](TaxonomyAssessment_v1#Spam.md) assessment is typically a feed depicting known malicious spam infrastructure.

# Details #
## Infrastructure ##

---

### API ###
```
GET https://cif.example.com:443/api/infrastructure/spam?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/spam?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/spam?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/spam -c 95
$ cif -q infrastructure/spam -c 85
$ cif -q infrastructure/spam -c 65
$ cif -q infrastructure/spam -c 95 -p iptables
$ cif -q infrastructure/spam -c 95 -p snort
```