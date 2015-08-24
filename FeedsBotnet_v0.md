

# Introduction #
The [botnet](TaxonomyImpact_v0#Botnet.md) assessment is typically a [high severity](TaxonomySeverity_v0#High.md) feed depicting things that would indicate a compromise.

# Details #
## Infrastructure ##
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
$ cif -q infrastructure/botnet -c 40
$ cif -q infrastructure/botnet -c 95 -p snort
$ cif -q infrastructure/botnet -c 95 -p iptables
```
## Domains ##
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
$ cif -q domain/botnet -c 40
$ cif -q domain/botnet -c 95 -p bindzone
$ cif -q domain/botnet -c 95 -p snort
```
## Urls ##
### API ###
```
GET https://cif.example.com:443/api/url/botnet?confidence=95&apikey=XXX
GET https://cif.example.com:443/api/url/botnet?confidence=85&apikey=XXX
GET https://cif.example.com:443/api/url/botnet?confidence=40&apikey=XXX
```

### CLI ###
```
$ cif -q url/botnet -c 95
$ cif -q url/botnet -c 85
$ cif -q url/botnet -c 40
$ cif -q url/botnet -c 95 -p snort
```