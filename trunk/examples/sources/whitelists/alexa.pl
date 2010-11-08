#!/usr/bin/perl -w

use CIF::Message::DomainWhitelist;
use DateTime;
use IO::Uncompress::Unzip qw(unzip $UnzipError);

my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';

my $url =
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
