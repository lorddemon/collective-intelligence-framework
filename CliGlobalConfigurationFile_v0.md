# Global Configuration File #
  1. create a configuration file: ~/.cif with the following:
```
[client]
# is the URL to the API of your CIF server
host = https://example.com:443/api

# the key used to access your server (generated with the cif_apikeys tool on the server).
apikey = xx-xx-xx-xx-xx

# how long to wait for a response from the server
timeout = 60

# can be set to 0 if you use a self-signed certificate on your server
#verify_tls = 0
```