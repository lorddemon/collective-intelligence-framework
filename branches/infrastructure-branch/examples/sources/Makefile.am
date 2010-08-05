AUTOMAKE_OPTIONS = foreign
SUBDIRS = malware networks phishing whitelists

install: install-recursive fixperms

fixperms:
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)
	chmod -R 770 $(prefix)
