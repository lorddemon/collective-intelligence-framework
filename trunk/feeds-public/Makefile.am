AUTOMAKE_OPTIONS = foreign

SUBDIRS = src 
#sysconfdir = $(prefix)/etc/cif
sysconfdir = /etc/cif

EXTRA_DIST = \
    src/alexa_whitelist.pl \
    src/cif_cron \
    rules/cron.cfg \
    rules/amada.cfg \
    rules/misc.cfg \
    rules/shadowserver.cfg \
    rules/spyeyetracker.cfg \
    rules/zeustracker.cfg

install: install-recursive fixperms

dist_sysconf_DATA = \
rules/cron.cfg \
rules/amada.cfg \
rules/misc.cfg \
rules/shadowserver.cfg \
rules/spyeyetracker.cfg \
rules/zeustracker.cfg

fixperms:
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)
	chmod -R o-rwx $(prefix)
