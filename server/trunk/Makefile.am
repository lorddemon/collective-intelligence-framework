EXTRA_DIST = lib etc sbin bin schemas schemas example_api.conf

all: default

default:
	@echo "Please read the README before beginning your installation."

fixperms:
	chmod 0755 $(prefix)
	chown -R $(CIF_USER) $(prefix)
	chgrp -R $(CIF_GROUP) $(prefix)

dirs:
	$(INSTALL) -m 0770 -d $(sysconfdir)
	$(INSTALL) -m 0775 -d $(prefix)/local
	$(INSTALL) -m 0770 -d $(prefix)/local/etc
	$(INSTALL) -m 0775 -d $(prefix)/local/lib

install: dirs files-install fixperms etc-link

files-install: libs-install etc-install bin-install local-whitelist

apikey:
	$(prefix)/bin/cif_apikeys -u root -a

depends: fixdeps

fixdeps:
	$(PERL) ./sbin/test-dependencies --verbose --install

testdeps:
	$(PERL) ./sbin/test-dependencies --verbose

local-whitelist:
	[ -e $(prefix)/etc/whitelist_domains ] || touch "$(prefix)/etc/whitelist_domains"
	[ -e $(prefix)/etc/whitelist_infrastructure ] || touch "$(prefix)/etc/whitelist_infrastructure"

etc-link:
	[ -d /etc/cif ] || ln -sf $(prefix)/etc /etc/cif

libs-install: 
	[ -d $(libdir) ] || $(INSTALL) -m 0755 -d $(libdir)
	-( cd lib && find . -type d -print ) | grep -v svn | while read dir ; do \
	$(INSTALL) -m 0755 -d "$(libdir)/$$dir" ; \
	done
	-( cd lib && find . -type f -print ) | grep -v svn | while read file ; do \
	$(INSTALL) -m 0644 "lib/$$file" "$(libdir)/$$file" ; \
	done

etc-install:
	[ -d $(sysconfdir) ] || $(INSTALL) -m 0770 -d $(sysconfdir)
	-( cd etc && find . -type f -print ) | grep -v svn | while read file ; do \
	    $(INSTALL) -m 0660 "etc/$$file" "$(sysconfdir)/$$file" ; \
	done

sbin-install:
	[ -d $(sbindir) ] || $(INSTALL) -m 0770 -d $(sbindir)
	-( cd lib && find . -type f -print ) | grep -v svn | while read file ; do \
        $(INSTALL) -m 0750 "sbin/$$file" "$(sbindir)/$$file" ; \
    done

bin-install:
	[ -d $(bindir) ] || $(INSTALL) -m 0770 -d $(bindir)
	-( cd bin && find . -type f -print ) | grep -v svn | while read file ; do \
		$(INSTALL) -m 0750 "bin/$$file" "$(bindir)/$$file" ; \
	done

initdb: createdb archive index 

createdb:
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -c 'CREATE DATABASE $(DB_DATABASE)'

archive:
	[ -d $(DB_ARCHIVE_LOC) ] || mkdir -p $(DB_ARCHIVE_LOC) && chown $(DB_UNIXOWNER):$(DB_UNIXOWNER) $(DB_ARCHIVE_LOC) 
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -d $(DB_DATABASE) -c "CREATE TABLESPACE archive LOCATION '$(DB_ARCHIVE_LOC)'"

index:
	[ -d $(DB_INDEX_LOC) ] || mkdir -p $(DB_INDEX_LOC) && chown $(DB_UNIXOWNER):$(DB_UNIXOWNER) $(DB_INDEX_LOC) 
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -d $(DB_DATABASE) -c "CREATE TABLESPACE index LOCATION '$(DB_INDEX_LOC)'"

tables: inittables tableindex

inittables:
	-( cd schemas/$(DB_TYPE) && find -type f -print | grep -v svn | sort ) | while read file ; do \
	$(PSQL) -U $(DB_DBA) -d $(DB_DATABASE) -h $(DB_HOST) -p $(DB_PORT) < "schemas/$(DB_TYPE)/$$file" ; \
	done
	@echo "Tables built"

tableindex:
	-( cd schemas/$(DB_TYPE)/index && find -type f -print | grep -v svn | sort ) | while read file ; do \
	$(PSQL) -U $(DB_DBA) -d $(DB_DATABASE) -h $(DB_HOST) -p $(DB_PORT) < "schemas/$(DB_TYPE)/index/$$file" ; \
	done
	@echo "Table Indicies built"

dropdb: dropdatabase droparchive dropindex          

dropdatabase:
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -c 'DROP DATABASE IF EXISTS $(DB_DATABASE)'

droparchive:
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -c "DROP TABLESPACE IF EXISTS archive"

dropindex:
	$(PSQL) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -c "DROP TABLESPACE IF EXISTS index"

backup:
	$(PGDUMP) -U $(DB_DBA) -h $(DB_HOST) -p $(DB_PORT) -v -a -f /tmp/cif_apikeys.sql -t apikeys -t apikeys_groups $(DB_DATABASE)

clean:
	rm Makefile
	rm config.log
	rm config.status

realclean: clean
	rm Makefile.in
	rm configure
	rm aclocal.m4

reconf:
	autoreconf -vf

BUILD=0.01-b$(shell date +%Y%m%d_%H%M%S)
SNAPSHOT=cif-$(BUILD)
snapshot: build-snapshot

build-snapshot:
	rm -Rf "/tmp/$(SNAPSHOT)"
	svn export ./ /tmp/$(SNAPSHOT)
	( cd /tmp/$(SNAPSHOT) && \
		echo "$(BUILD)" > .tag && \
		sh rebuild.sh && \
		make dist && \
		cp $(SNAPSHOT).tar.gz /tmp/ \
	)
	rm -R -f "/tmp/$(SNAPSHOT)"
