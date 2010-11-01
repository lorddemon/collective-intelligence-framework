AUTOMAKE_OPTIONS = foreign

EXTRA_DIST = \
    malware/fire_block.pl \
    malware/malwaredomainlist.pl \
    malware/malwaredomains.pl \
    malware/zt_binaries.pl \
    malware/zt_configs.pl \
    malware/zt_domains_blocklist.pl \
    malware/zt_domains.pl \
    malware/zt_ip_blocklist.pl \
    networks/spamhaus_drop.pl \
    phishing/phishtank.pl \
    phishing/phishing_replyto.pl \
    whitelists/whitelist_dnswl_org.pl \
    whitelists/local_domain_whitelist.pl \
    whitelists/local_inet_whitelist.pl

SUBDIRS = malware networks phishing whitelists

install: install-recursive fixperms

fixperms:
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)
	chmod -R o-rwx $(prefix)
