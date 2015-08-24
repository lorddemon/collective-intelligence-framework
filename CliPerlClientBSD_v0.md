# Introduction #

Care of our friends @ scranton.edu.

# Details #
```
#!/usr/local/bin/bash

PORTS=(/ftp/wget /devel/p5-File-Remove /www/p5-HTTP-Server-Simple /devel/p5-Module-Install /devel/p5-Module-ScanDeps /devel/p5-PAR-Dist /security/p5-Crypt-SSLeay /textproc/p5-Text-Table /www/p5-HTML-Table /converters/p5-JSON-PP /converters/p5-JSON /converters/p5-JSON-XS /devel/p5-Module-Pluggable /devel/p5-Config-Simple /security/p5-Snort-Rule /devel/p5-Class-Accessor /textproc/p5-Regexp-Common /textproc/p5-Regexp-Common-net-CIDR /security/p5-Digest-MD5 /security/p5-Digest-SHA1)
PORTSDIR='/usr/ports'

echo "Installing dependencies from ports"
for port in ${PORTS[@]}
do
    PORTNAME=`echo $port | /usr/bin/cut -d '/' -f3`
    /usr/sbin/pkg_info | /usr/bin/grep -q "${PORTNAME}"
    if [ "$?" -eq 0 ]; then
        echo "${port} is installed"
    else
        echo "Installing ${port}"
        cd ${PORTSDIR}${port}
        /usr/bin/make clean
        /usr/bin/make rmconfig
        /usr/bin/make config
        /usr/bin/make install clean
    fi
done

echo "Installing REST::Client from CPAN"
cd ~/
/usr/bin/perl -MCPAN -e 'install REST::Client'

echo "Installing CIF::Client from CPAN"
/usr/bin/perl -MCPAN -e 'install CIF::Client'

echo "Moving bsdpan ports from /var/db/pkg to /root/pkg"
echo " See: http://www.freebsd.org/cgi/query-pr.cgi?pr=140273"
/bin/mkdir -p /root/pkg
/bin/mv -f /var/db/pkg/bsdpan-* /root/pkg/

# Needed in case this is a reinstall/upgrade
if [ -d "/var/db/pkg/bsdpan-*" ]; then
   /bin/rm -rf "/var/db/pkg/bsdpan-*" > /dev/null 2>&1
fi

echo "Writing .cif configuration file to homedir"
echo '[client]' > ~/.cif
echo 'host = https://YOUR-CIF-SERVER:443/api' >> ~/.cif
echo 'apikey = YOUR-API-KEY' >> ~/.cif
echo 'timeout = 60' >> ~/.cif
echo 'verify_tls = 0' >> ~/.cif
chmod 0400 ~/.cif
```