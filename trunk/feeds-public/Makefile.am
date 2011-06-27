AUTOMAKE_OPTIONS = foreign

SUBDIRS = src 
sysconfdir = /etc/cif

EXTRA_DIST = \
    src/cif_crontool 

install: install-recursive fixperms

dist_sysconf_DATA = \
etc/amada.cfg \
etc/misc.cfg \
etc/shadowserver.cfg \
etc/spyeyetracker.cfg \
etc/00_whitelist.cfg \
etc/custom.cfg.example \
etc/zeustracker.cfg

fixperms:
	chown -R $(CIF_USER) $(prefix) $(sysconfdir)
	chgrp -R $(CIF_GROUP) $(prefix) $(sysconfdir)
	chmod -R o-rwx $(prefix) $(sysconfdir)
	chmod -R g+w $(sysconfdir)
