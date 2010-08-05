#!/bin/bash

W=`whoami`
if [ $W == 'root' ]; then
    perl -MCPAN -e 'install DateTime,DateTime::Format::DateParse, Net::Utils::Abuse, XML::RSS. Net::DNS, Regexp::Common::net, LWP::Simple'
else
    echo 'you must run this as root, try again with sudo'
fi
