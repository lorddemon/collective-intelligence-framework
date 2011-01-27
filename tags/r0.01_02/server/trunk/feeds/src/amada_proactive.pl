#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use DateTime::Format::DateParse;
use DateTime;
use Net::DNS;

use CIF::Message::DomainSimple;

my $timeout = 5;
my $partner = 'amada.abuse.ch';
my $url = 'http://amada.abuse.ch/blocklist.php?download=proactivelistings';

my $content = get($url);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);

    m/^([A-Za-z0-9.-]+\.[a-zA-Z]{2,6}) # (\S+)/;
    my $domain = $1;
    my $desc = $2 || '';
    next unless($domain);

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $impact = 'malware domain '.$desc;
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
        alternativeid => 'http://amada.abuse.ch/?search='.$domain,
        alternativeid_restriction => 'public',
    });
    my $uuid = ($u =~ /^\d+/) ? $u->uuid() : '';
    print $u.' -- '.$uuid.' -- '.$domain."\n";
}
