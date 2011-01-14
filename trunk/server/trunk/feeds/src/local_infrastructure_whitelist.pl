#!/usr/bin/perl -w

use CIF::Message::InfrastructureSimple;
use DateTime;
my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';

# your own personal whitelist;
my $list = '/tmp/inet_whitelist.txt';

open(F,$list);

while(<F>){
    my $line = $_;
    $line =~ s/\n//;

    my $id = CIF::Message::InfrastructureSimple->insert({
        source      => 'localhost',
        impact      => 'infrastructure whitelist',
        description => 'infrastructure whitelist '.$line,
        address     => $line,
        confidence  => 10,
        detecttime  => $date,
        restriction => 'need-to-know',
        alternativeid => '',
        alternativeid_restriction => '',
    });
    warn $id;
}
close(F);
