# Introduction #

---


This doc shows an example of how to proxy your resolution requests through google dns while still filtering out specific spamhaus requests direction to spamhaus

## 1. Configure Bind ##

---

1. Configure Bind (/etc/bind/named.conf.options)
```
options {
    directory "/var/cache/bind";

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

# 2. Reload Bind #

---

be sure to reload bind when you're done
```
$ sudo /etc/init.d/bind9 restart
```

## References ##

---

  * http://www.spamhaus.org/zen/
  * http://www.spamhaus.org/dbl/
  * http://www.spamhaus.org/faq/answers.lasso?section=DNSBL%20Usage
  * http://www.team-cymru.org/Services/ip-to-asn.html
  * http://www.bind9.net/BIND-FAQ