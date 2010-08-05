package CIF::Message::InetSimple;
use base 'CIF::Message::Inet';

use strict;
use warnings;

use CIF::Message::InetWhitelist;
use CIF::Message::Inet;
use CIF::Message::Infrastructure;
use CIF::Message::SuspiciousNetwork;
use CIF::Message::Spammer;
use CIF::Message::Scanner;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    return 0 unless($info->{'address'} =~ /^$RE{net}{IPv4}/);
    return 0 if(CIF::Message::Inet::isPrivateAddress($info->{'address'}));
    return 0 if(CIF::Message::InetWhitelist::isWhitelisted($info->{'address'}));

    my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Inet::asninfo($info->{'address'});

    my $bucket = 'CIF::Message::Infrastructure';
    my $description = $info->{'description'};
    my $addr = $info->{'address'};
    unless($description =~ /$addr/){
        $description .= ' '.$info->{'address'};
    }
    my $impact = 'suspicious infrastructure';
    for(lc($info->{'description'})){
        if(/botnet/){
            $impact = 'botnet infrastructure';
            last;
        }
        if(/malware/){
            $impact = 'malware infrastructure';
            last;
        }
        if(/scanner/){
            $bucket = 'CIF::Message::Scanner';
            $impact = 'scanner';
            last;
        }
        if(/spammer/){
            $bucket = 'CIF::Message::Spammer';
            $impact = 'spammer';
            last;
        }
        if(/network/){
            $bucket = 'CIF::Message::SuspiciousNetwork';
            $impact = 'suspicious network';
            last;
        }
    }

    my $id = $bucket->insert({
        relatedid   => $info->{'relatedid'},
        address     => $info->{'address'},
        source      => $info->{'source'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        portlist    => $info->{'portlist'},
        protocol    => $info->{'protocol'},
        impact      => $impact,
        description => $description,
        detecttime  => $info->{'detecttime'},
        asn         => $as,
        asn_desc    => $as_desc,
        cidr        => $network,
        cc          => $ccode,
        rir         => $rir,
        restriction => $info->{'restriction'} || 'private',
        alternativeid => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'},
    });
    return $id;
}

1;
