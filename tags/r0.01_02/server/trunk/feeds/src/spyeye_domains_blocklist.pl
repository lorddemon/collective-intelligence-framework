#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use DateTime::Format::DateParse;
use DateTime;
use Net::DNS;

use CIF::Message::DomainSimple;

my $timeout = 5;
my $partner = 'spyeyetracker.abuse.ch';
my $url = 'https://spyeyetracker.abuse.ch/blocklist.php?download=domainblocklist';

my $content = get($url);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);
    my $domain = $_;

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $impact = 'spyeye malware domain';
    my $description = $impact.' '.$domain;

    my $u = CIF::Message::DomainSimple->insert({
        nsres       => Net::DNS::Resolver->new(['8.8.8.8','8.8.8.4']),
        address     => $domain,
        source      => $partner,
        confidence  => 7,
        severity    => 'low',
        impact      => $impact,
        description => $description,
        detecttime  => $detecttime,
        restriction => 'need-to-know',
        alternativeid => 'https://spyeyetracker.abuse.ch/monitor.php?host='.$domain,
        alternativeid_restriction => 'public',
    });
    warn $u;
}
