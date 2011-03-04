package CIF::Message::UrlSimple;
use base 'CIF::Message::Url';

use strict;
use warnings;

require CIF::Message::UrlMalware;
require CIF::Message::UrlPhishing;
require CIF::Message::DomainSimple;
require CIF::Message::InfrastructureSimple;
require CIF::Message::UrlBotnet;
use Regexp::Common qw/net URI/;
use Digest::MD5 qw/md5_hex/;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $bucket = 'CIF::Message::UrlMalware';
    my $impact = lc($info->{'impact'});

    for($impact){
        if(/botnet/){
            $bucket = 'CIF::Message::UrlBotnet';       
            last;
        }
        if(/phish/){
            $bucket = 'CIF::Message::UrlPhishing';
            last;
        }
    }

    my $id = $bucket->insert({
        relatedid   => $info->{'relatedid'},
        address     => $info->{'address'},
        source      => $info->{'source'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        impact      => $impact,
        description => $info->{'description'},
        malware_md5 => $info->{'malware_md5'},
        malware_sha1 => $info->{'malware_sha1'},
        detecttime  => $info->{'detecttime'},
        restriction => $info->{'restriction'} || 'private',
        alternativeid => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'},
    });

    $impact = 'malware ';
    for($impact){
        if(/botnet/){
            $impact = 'botnet ';
            last;
        }
        if(/phish/){
            $impact = 'phishing ';
            last;
        }
    }

    my $address = $info->{'address'};
    my $port;
    if($address =~ /^(https?\:\/\/)?([A-Za-z-]+\.[a-z]{2,5})(:\d+)?\//){
        $bucket = 'CIF::Message::DomainSimple';
        $impact .= 'domain';
        $address = $2;
        $port = (defined($1) && $1 eq 'https') ? 443 : 80;
        if($3){
            $port = $3;
            $port =~ s/^://;
        }
    } elsif($address =~ /^(https?\:\/\/)?($RE{'net'}{'IPv4'})(:\d+)?\//) {
        $address = $2;
        $impact .= 'infrastructure';
        $port = (defined($1) && $1 eq 'https') ? 443 : 80;
        if($3){
            $port = $3;
            $port =~ s/^://;
        }
        $bucket = 'CIF::Message::InfrastructureSimple';
    } else {
        return $id;
    }
    $bucket->insert({
            nsres       => $info->{'nsres'},
            relatedid   => $id->uuid(),
            address     => $address,
            source      => $info->{'source'},
            confidence  => ($info->{'confidence'} - 2),
            severity    => ($info->{'severity'} eq 'high') ? 'medium' : 'low',
            impact      => $impact,
            description => $info->{'description'},
            detecttime  => $info->{'detecttime'},
            restriction => $info->{'restriction'} || 'private',
            alternativeid => $info->{'alternativeid'},
            alternativeid_restriction => $info->{'alternativeid_restriction'},
            portlist    => $port,
    });
    return $id;
}

1;
