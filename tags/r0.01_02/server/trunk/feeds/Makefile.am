AUTOMAKE_OPTIONS = foreign

EXTRA_DIST = \
    src/amada_proactive.pl \
    src/amada_ipblocklist.pl \
    src/malc0de.pl \
    src/maliciousnetworks.org_firelist.pl \
    src/malwaredomainlist.pl \
    src/malwaredomains.pl \
    src/zeustracker_binaries.pl \
    src/zeustracker_configs.pl \
    src/zeustracker_domains_blocklist.pl \
    src/zeustracker_domains.pl \
    src/zeustracker_ip_blocklist.pl \
    src/spamhaus_drop.pl \
    src/phishtank.pl \
    src/google_phishing_replyto.pl \
    src/whitelist_dnswl_org.pl \
    src/local_domain_whitelist.pl \
    src/local_infrastructure_whitelist.pl \
    src/alexa_whitelist.pl \
    src/hosts-file.net.pl \
    src/mpatrol_hashes.pl \
    src/mpatrol_urls.pl \
    src/spyeye_binaries.pl \
    src/spyeye_configs.pl \
    src/spyeye_domains_blocklist.pl \
    src/spyeye_domains.pl \
    src/spyeye_ip_blocklist.pl \
    src/sshbl.pl \
    src/threatexpert.pl \
    src/cron.sh

SUBDIRS = src 

install: install-recursive fixperms

fixperms:
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)
	chmod -R o-rwx $(prefix)
