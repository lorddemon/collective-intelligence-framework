#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use CIF::Message::InfrastructureSimple;
use CIF::Message::Infrastructure;
use LWP::Simple;

my $url = 'http://maliciousnetworks.org/fire-blocklist.txt';
my $dt = DateTime->from_epoch(epoch => time());
$dt = $dt->ymd().'T00:00:00Z';

my $content = get($url) || die('failed to get url: '.$!);
my @lines = split(/\n/,$content);

foreach (@lines){
    next if(/^#/);
    next if(/^$/);
    next if(/^\r/);
    my ($addr,$asn) = split(/\s+/,$_);

    warn CIF::Message::InfrastructureSimple->insert({
        address     => $addr,
        source      => 'maliciousnetworks.org',
        description => 'suspicious address '.$addr,
        impact      => 'suspicious address',
        confidence  => 3,
        severity    => 'medium',
        restriction => 'need-to-know',
        alternativeid  => 'http://maliciousnetworks.org/ipinfo.php?as='.$asn,
        alternativeid_restriction => 'public',
        detecttime  => $dt,
    });
}
