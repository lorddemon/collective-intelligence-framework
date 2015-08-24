# Introduction #

---


This doc shows an example of how to proxy your resolution requests through Google dns while still filtering out specific Spamhaus requests direction to Spamhaus

## Configure Bind ##

---

  1. modify the config file
    * **Debian Based** (Debian, Ubuntu, etc)
```
$ sudo vi /etc/bind/named.conf.options
```
    * **RHEL Based** (RHEL, CentOS, etc)
```
$ sudo vi /etc/named.conf
```
  1. Configure the file to look something like this:
```
options {
    // If there is a firewall between you and nameservers you want
    // to talk to, you may need to fix the firewall to allow multiple
    // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

    // If your ISP provided one or more IP addresses for stable
    // nameservers, you probably want to use them as forwarders.
    // Uncomment the following block, and insert the addresses replacing
    // the all-0's placeholder.
    forward only;
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    auth-nxdomain no;    # conform to RFC1035
    // listen-on-v6 { any; };
    listen-on { 127.0.0.1; };
};

// bypass the Google public servers
zone "cymru.com" {
    forward only;
    type forward;
    forwarders { };
};

zone "zen.spamhaus.org" {
    forward only;
    type forward;
    forwarders { };
};

zone "dbl.spamhaus.org" {
    forward only;
    type forward;
    forwarders { };
};
```
  1. reload bind
    * Debian 6.0.x
```
$ sudo /etc/init.d/bind9 restart
```
    * Ubuntu 12.04
```
$ sudo service bind9 restart
```
    * RHEL
```
$ sudo /etc/init.d/named restart
```
  1. verify bind is working
```
$ dig ns1.google.com
```
```
...
ns1.google.com.         21588   IN      A       216.239.32.10
...
;; SERVER: 127.0.0.1#53(127.0.0.1)
```

## References ##

---

  * http://www.spamhaus.org/zen/
  * http://www.spamhaus.org/dbl/
  * http://www.spamhaus.org/faq/answers.lasso?section=DNSBL%20Usage
  * http://www.team-cymru.org/Services/ip-to-asn.html
  * http://www.bind9.net/BIND-FAQ