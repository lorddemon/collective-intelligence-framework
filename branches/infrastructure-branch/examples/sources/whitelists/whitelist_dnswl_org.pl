#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use DateTime;
use Net::Abuse::Utils qw(:all);
use CIF::Message::DomainWhitelist;
use CIF::Message::InfrastructureWhitelist;
use CIF::Message::Infrastructure;

my $detecttime = DateTime->from_epoch(epoch => time());

#system('rsync --times rsync1.dnswl.org::dnswl/generic-* /tmp/');

my %hash;
my $cat = {
    1   => 'NA',
    2   => 'financial services',
    3   => 'email service provider',
    4   => 'organizations (both for-profit and non-profit)',
    5   => 'service/network provider',
    6   => 'personal/private servers',
    7   => 'travel/liesure industry',
    8   => 'public sector/govt',
    9   => 'media and tech companies',
    10  => 'special case',
    11  => 'education/acedemic',
    12  => 'healthcare',
    13  => 'manufacturing/industrial',
    14  => 'retail/wholesale/servers',
    15  => 'email marketing provider'
};

open(F,'/tmp/generic-dnswl');
while(<F>){
    next if(/^(#|\n|$)/);
    my $line = $_;
    $line =~ s/\n//;
    my ($address,$c,$trust,$domain,$id) = split(/;/,$line);
    my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Infrastructure::asninfo($address);

    my $impact = 'domain whitelist';
    $impact .= ' '.$cat->{$c} if($c);

    my $uid = CIF::Message::DomainWhitelist->insert({
        address         => $domain,
        confidence      => 5,
        source          => 'dnswl.org',
        restriction     => 'need-to-know',
        description     => $impact.' '.$domain,
        impact          => $impact,
        alternativeid   => 'http://www.dnswl.org/search.pl?s='.$id,
        alternativeid_restriction   => 'public',
        detecttime      => $detecttime->ymd().'T00:00:00Z',
        rdata           => $address,
        asn             => $as,
        asn_desc        => $as_desc,
        cc              => $ccode,
        cidr            => $network,
        rir             => $rir
    });

    $impact = 'infrastructure whitelist';
    $impact .= ' '.$cat->{$c} if($c);

    my $iid = CIF::Message::InfrastructureWhitelist->insert({
        relatedid         => $uid->uuid(),
        address         => $address,
        confidence      => 5,
        source          => 'dnswl.org',
        restriction     => 'need-to-know',
        description     => $impact.' '.$domain.' '.$address,
        impact          => $impact,
        alternativeid   => 'http://www.dnswl.org/search.pl?s='.$id,
        alternativeid_restriction   => 'public',
        detecttime      => $detecttime->ymd().'T00:00:00Z',
        asn             => $as,
        asn_desc        => $as_desc,
        cidr            => $network,
        cc              => $ccode,
        rir             => $rir,
    });
    warn $uid;
    warn $iid;
}
close(F);
