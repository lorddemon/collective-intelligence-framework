AUTOMAKE_OPTIONS = foreign

SUBDIRS = src 
sysconfdir = /etc/cif

EXTRA_DIST = \
    src/alexa_whitelist.pl \
    src/cif_cron \
    etc/cron.cfg \
    etc/amada.cfg \
    etc/misc.cfg \
    etc/shadowserver.cfg \
    etc/spyeyetracker.cfg \
    etc/zeustracker.cfg

install: install-recursive fixperms

dist_sysconf_DATA = \
etc/cron.cfg \
etc/feeds/amada.cfg \
etc/feeds/misc.cfg \
etc/feeds/shadowserver.cfg \
etc/feeds/spyeyetracker.cfg \
etc/feeds/zeustracker.cfg

fixperms:
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)
	chmod -R o-rwx $(prefix)
