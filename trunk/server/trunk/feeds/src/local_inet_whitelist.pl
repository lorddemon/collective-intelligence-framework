#!/usr/bin/perl -w

use CIF::Message::InetWhitelist;
use CIF::Message::Inet;
use DateTime;
my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';

# your own personal whitelist;
my $list = '/tmp/inet_whitelist.txt';

open(F,$list);

while(<F>){
    my $line = $_;
    $line =~ s/\n//;

    my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Inet::asninfo($line);

    my $id = CIF::Message::InetWhitelist->insert({
        source      => 'localhost',
        impact      => 'inet whitelist',
        description => 'inet whitelist '.$line,
        address     => $line,
        confidence  => 10,
        detecttime  => $date,
        restriction => 'need-to-know',
        asn         => $as,
        asn_desc    => $as_desc,
        cc          => $ccode,
        rir         => $rir,
        cidr        => $network
    });
    warn $id;
}
close(F);
