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
use CIF::Message::InfrastructureScanner;
use CIF::Message::InfrastructurePhishing;
use CIF::Message::InfrastructureSuspicious;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    return 0 unless($info->{'address'} =~ /^$RE{net}{IPv4}/);
    return 0 if(CIF::Message::Infrastructure::isPrivateAddress($info->{'address'}));
    return 0 if(CIF::Message::InfrastructureWhitelist::isWhitelisted($info->{'address'}));

    my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Infrastructure::asninfo($info->{'address'});

    my $bucket;
    my $description = $info->{'description'};
    my $addr = $info->{'address'};
    unless($description =~ /$addr/){
        $description .= ' '.$info->{'address'};
    }
    my $impact = $info->{'impact'};
    for(lc($info->{'description'})){
        if(/botnet/){
            $bucket = 'CIF::Message::InfrastructureBotnet';
            $impact = 'botnet infrastructure' unless($impact);
            last;
        }
        if(/malware/){
            $bucket = 'CIF::Message::InfrastructureMalware';
            $impact = 'malware infrastructure' unless($impact);
            last;
        }
        if(/scanner/){
            $bucket = 'CIF::Message::InfrastructureScanner';
            $impact = 'scanner infrastructure' unless($impact);
            last;
        }
        if(/spammer/){
            $bucket = 'CIF::Message::InfrastructureSpam';
            $impact = 'spam infrastructure' unless($impact);
            last;
        }
        if(/network/){
            $bucket = 'CIF::Message::InfrastructureNetwork';
            $impact = 'suspicious network infrastructure' unless($impact);
            last;
        }
        if(/phish/){
            $bucket = 'CIF::Message::InfrastructurePhishing';
            $impact = 'phishing infrastructure' unless($impact);
            last;
        }
        $bucket = 'CIF::Message::InfrastructureSuspicious';
        $impact = 'suspicious infrastructure' unless($impact);
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
