
```
--begin install script--
#!/usr/local/bin/bash

PORTS=(/ftp/wget /security/p5-Crypt-SSLeay /textproc/p5-Text-Table /converters/p5-JSON /devel/p5-Module-Pluggable /devel/p5-Config-Simple /security/p5-Snort-Rule /devel/p5-Class-Accessor  /textproc/p5-Regexp-Common /security/p5-Digest-MD5 /security/p5-Digest-SHA1)
PORTSDIR='/usr/ports'

for port in ${PORTS[@]}
do
   echo Installing ${port}
   cd ${PORTSDIR}${port}
   /usr/bin/make clean
   /usr/bin/make config
   /usr/bin/make install clean
done

cd ~/
/usr/bin/perl -MCPAN -e 'install REST::Client'
/usr/local/bin/wget --output-document='CIF-Client-0.00_03.tar.gz' http://search.cpan.org/CPAN/authors/id/S/SA/SAXJAZMAN/cif/CIF-Client-0.00_03.tar.gz 
/usr/bin/tar -zxvf CIF-Client-0.00_03.tar.gz
cd CIF-Client-0.00_03
/usr/bin/perl Makefile.PL && make && make install
--end install script--
```