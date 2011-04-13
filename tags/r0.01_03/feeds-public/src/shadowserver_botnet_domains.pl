#!/usr/bin/perl -w

use strict;

use LWP::Simple;
use DateTime;
use Net::DNS;
use Data::Dumper;
use CIF::Message::DomainSimple;

my $url = 'http://www.shadowserver.org/ccdns.php';
my $partner = 'shadowserver.org';

my $content = get($url);

die $content if($content =~ /You are seeing this message instead of the contents/);

my @lines = split(/\n/,$content);

my $detecttime = DateTime->from_epoch(epoch => time());
$detecttime = $detecttime->ymd().'T00:00:00Z';

foreach my $domain (@lines){
    next unless($domain =~ /^(?:[a-zA-Z0-9.-]+)[a-zA-Z0-9]{2,4}$/);
    my $id = CIF::Message::DomainSimple->insert({
        address     => $domain,
        restriction => 'need-to-know',
        detecttime  => $detecttime,
        severity    => 'medium',
        confidence  => 7,
        impact      => 'botnet domain',
        description => 'botnet domain '.$domain,
        source      => $partner,
    });
    my $uuid = ($id =~ /^\d+$/) ? $id->uuid() : $id;
    print $partner.' -- '.$domain.' -- '.$detecttime.' -- '.$uuid."\n";
}
