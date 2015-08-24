# Introduction #
  * This was tested on a Ubuntu 10.04.3 server
  * This was tested using Bind 9.7.0
  * This documentation is written with the client (libcif) installed on the Bind server.

# Details #
## Configure the CIF client ##

  1. Open the client configuration file
```
vim .cif
```
  1. Add the following under the 'client' section of the ~/.cif config
```
bindzone_path = /etc/bind/
```
    * example config
```
[client]
apikey = xx-xx-xx-xx-xx
bindzone_path = /etc/bind/

[client_http]
host = https://example.com/api
timeout = 60
#verify_tls = 0
```

## Configure Bind ##

  1. Edit named.conf
```
sudo vim /etc/bind/named.conf
```
  1. Add the following
```
include "/var/lib/bind/sink_local.conf";
```
  1. Create a sink\_local.conf file
```
sudo touch /var/lib/bind/sink_local.conf
```
  1. Change permissions on sink\_local.conf file to root:bind
```
sudo chown root:bind /var/lib/bind/sink_local.conf
```
  1. Run the command "named-checkconf" to make sure you have no errors in your named.conf file.
```
sudo /usr/sbin/named-checkconf
```
  1. Create a zone file
```
sudo vim /etc/bind/cif_domain_malware.zone
```
  1. Copy the following
```
$TTL 600

@       IN      SOA     localhost     root (
                        1               ; serial number
                        3H              ; Refresh
                        15M             ; Retry
                        1W              ; Expire
                        1D )            ; Min TTL

        24H IN NS              @
        24H IN A               127.0.0.1
*       24H IN A               127.0.0.1
```
  1. For '''testing / demonstration''' purposes only, allow any user to write to the
```
sudo chmod 666 /var/lib/bind/sink_local.conf
```
  1. Configure the client to export a sinkhole file
```
/usr/local/bin/cif -q domain/malware -p bindzone -c 85 > /var/lib/bind/sink_local.conf
```
  1. Reload configuration file and new zones only
```
sudo /usr/sbin/rndc reconfig
```
  1. Run the command "named-checkconf" to make sure you have no errors
```
sudo /usr/sbin/named-checkconf
```

## Test the configuration ##
  1. Find a domain in sink\_local.conf
```
cat /var/lib/bind/sink_local.conf
```
  1. Test the domain against the local server using dig
```
dig @localhost hjmnuuyej1152klu.com
```
    * Example results
```
; <<>> DiG 9.7.0-P1 <<>> @localhost hjmnuuyej1152klu.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17755
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;hjmnuuyej1152klu.com.          IN      A

;; ANSWER SECTION:
hjmnuuyej1152klu.com.   86400   IN      A       127.0.0.1

;; AUTHORITY SECTION:
hjmnuuyej1152klu.com.   86400   IN      NS      hjmnuuyej1152klu.com.

;; Query time: 42 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Jan 19 10:55:03 2012
;; MSG SIZE  rcvd: 68
```

# External References #
  * https://github.com/mrmuth/SafeDNS