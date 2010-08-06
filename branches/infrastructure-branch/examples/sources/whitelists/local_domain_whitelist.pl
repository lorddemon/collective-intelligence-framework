#!/usr/bin/perl -w

use CIF::Message::DomainWhitelist;
use DateTime;
my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';

# your own personal whitelist;
my $list = '/tmp/domain_whitelist.txt';

open(F,$list);

while(<F>){
    my $line = $_;
    $line =~ s/\n//;
    my $id = CIF::Message::DomainWhitelist->insert({
        source      => 'localhost',
        impact      => 'domain whitelist',
        description => 'domain whitelist '.$line,
        address     => $line,
        confidence  => 10,
        detecttime  => $date,
        restriction => 'need-to-know',
    });
    warn $id;
}
close(F);
