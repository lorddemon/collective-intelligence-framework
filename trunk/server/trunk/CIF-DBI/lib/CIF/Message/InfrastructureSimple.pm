package CIF::Message::InfrastructureSimple;
use base 'CIF::Message::Infrastructure';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use CIF::Message::InfrastructureWhitelist;
use CIF::Message::InfrastructureBotnet;
use CIF::Message::InfrastructureMalware;
use CIF::Message::InfrastructureNetwork;
use CIF::Message::InfrastructureSpam;
use CIF::Message::InfrastructureScan;
use CIF::Message::InfrastructurePhishing;
use CIF::Message::InfrastructureSuspicious;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    return (undef,'invaild address: private address') if(CIF::Message::Infrastructure::isPrivateAddress($info->{'address'}));
    return (undef,'invalid address: whitelisted address') if(CIF::Message::Infrastructure::isWhitelisted($info->{'address'}));

    my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Infrastructure::asninfo($info->{'address'});

    my $bucket;
    my $description = $info->{'description'};
    my $addr = $info->{'address'};
    unless($description =~ /$addr/){
        $description .= ' '.$info->{'address'};
    }
    my $impact = $info->{'impact'};
    for(lc($impact)){
        if(/botnet/){
            $bucket = 'CIF::Message::InfrastructureBotnet';
            last;
        }
        if(/malware|malicious/){
            $bucket = 'CIF::Message::InfrastructureMalware';
            last;
        }
        if(/scanner/){
            $bucket = 'CIF::Message::InfrastructureScan';
            last;
        }
        if(/spammer/){
            $bucket = 'CIF::Message::InfrastructureSpam';
            last;
        }
        if(/network/){
            $bucket = 'CIF::Message::InfrastructureNetwork';
            last;
        }
        if(/phish/){
            $bucket = 'CIF::Message::InfrastructurePhishing';
            last;
        }
        if(/whitelist/){
            $bucket = 'CIF::Message::InfrastructureWhitelist';
            last;
        }
        $bucket = 'CIF::Message::InfrastructureSuspicious';
        $impact = 'suspicious infrastructure' unless($impact);
    }

    return $bucket->insert({
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
}

1;
