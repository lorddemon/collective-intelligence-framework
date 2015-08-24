# Generating API Keys #
```
$ cif_apikeys -h
Usage: perl /usr/local/bin/cif_apikeys -u joe@example.com
    -h  --help:     this meessage
    -e  --enable:   enable access to specific section (infrastructure,domains,malware,etc... default: all)
    -r  --revoke:   revoke a key
    -w  --write:    enable write access
    -a  --add:      add key
    -d  --delete:   delete key
    -k  --key:      apikey

Examples:
    $> perl /usr/local/bin/cif_apikeys -u joe@example.com
    $> perl /usr/local/bin/cif_apikeys -u joe@example.com -a
    $> perl /usr/local/bin/cif_apikeys -d -k 96818121-f1b6-482e-8851-8fb49cb2f6c0
    $> perl /usr/local/bin/cif_apikeys -u joe@example.com -e infrastructure -a
    $> perl /usr/local/bin/cif_apikeys -k 96818121-f1b6-482e-8851-8fb49cb2f6c0 -w
    $> perl /usr/local/bin/cif_apikeys -k 96818121-f1b6-482e-8851-8fb49cb2f6c0 -r
```