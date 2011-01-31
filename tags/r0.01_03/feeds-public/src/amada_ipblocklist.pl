#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use DateTime;
use Regexp::Common qw/net/;

use CIF::Message::InfrastructureSimple;

my $timeout = 5;
my $partner = 'amada.abuse.ch';
my $url = 'http://amada.abuse.ch/blocklist.php?download=ipblocklist';

my $content = get($url);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);

    m/^($RE{'net'}{'IPv4'}) # (\S+)/;
    my $addr = $1;
    my $desc = $2 || '';
    next unless($addr);

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $impact = 'suspicious infrastructure '.$desc;
    my $description = $impact.' '.$addr;

    my $u = CIF::Message::InfrastructureSimple->insert({
        address     => $addr,
        source      => $partner,
        confidence  => 7,
        severity    => 'low',
        impact      => $impact,
        description => $description,
        detecttime  => $detecttime,
        restriction => 'need-to-know',
        alternativeid => 'http://amada.abuse.ch/?search='.$addr,
        alternativeid_restriction => 'public',
    });
    print $u.' -- '.$u->uuid.' -- '.$addr."\n";
}
