#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use Data::Dumper;
use DateTime;

use CIF::Message::InfrastructureSimple;

my $partner = 'zeustracker.abuse.ch';
my $url = 'https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist';

my $content = get($url);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);
    my $address = $_;

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $impact = 'zeus botnet infrastructure';
            
    my $u = CIF::Message::InfrastructureSimple->insert({
        source      => $partner,
        address     => $address,
        impact      => $impact,
        description => $impact.' '.$address,
        confidence  => 5,
        severity    => 'low',
        detecttime  => $detecttime,
        restriction => 'need-to-know',
        alternativeid => 'https://zeustracker.abuse.ch/monitor.php?ipaddress='.$address,
        alternativeid_restriction => 'public',
    });
    warn $u;
}
