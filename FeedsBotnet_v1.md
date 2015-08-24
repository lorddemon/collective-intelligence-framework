<font color='red'>
<h1>Unstable</h1>
<ul><li>fix api examples<br>
</font></li></ul>



# Introduction #
The [botnet](TaxonomyAssessment_v1#Botnet.md) assessment is typically a feed depicting things that would indicate a compromise. (e.g. only a compromised machine would connect to a botnet command and control server.)

# Details #
## Infrastructure ##

---

### API ###
```
GET https://cif.example.com:443/api/infrastructure/botnet?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/botnet?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/infrastructure/botnet?confidence=40&apikey=XXX
```

### CLI ###
```
$ cif -q infrastructure/botnet -c 95
$ cif -q infrastructure/botnet -c 85
$ cif -q infrastructure/botnet -c 65
$ cif -q infrastructure/botnet -c 95 -p snort
$ cif -q infrastructure/botnet -c 95 -p iptables
```
## Domains ##

---

### API ###
```
GET https://cif.example.com:443/api/domain/botnet?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/domain/botnet?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/domain/botnet?confidence=40&apikey=XXX
```

### CLI ###
```
$ cif -q domain/botnet -c 95
$ cif -q domain/botnet -c 85
$ cif -q domain/botnet -c 65
$ cif -q domain/botnet -c 95 -p bindzone
$ cif -q domain/botnet -c 95 -p snort
```
## Urls ##

---

### API ###
```
GET https://cif.example.com:443/api/url/botnet?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/url/botnet?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/url/botnet?confidence=65&apikey=XXX
```

### CLI ###
```
$ cif -q url/botnet -c 95
$ cif -q url/botnet -c 85
$ cif -q url/botnet -c 65
$ cif -q url/botnet -c 95 -p snort
```