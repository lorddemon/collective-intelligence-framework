#!/usr/bin/perl -w

use CIF::Message::InfrastructureSimple;
use DateTime;
use Config::Simple;

# your own personal whitelist;
my $cfg = Config::Simple->new($ENV{'HOME'}.'/.cif') || die($!);
my $feed = $cfg->param(-block => 'feed_sources')->{'infrastructure_whitelist'} || die('missing feed: '.$!);

open(F,$feed) || die($!);

my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';

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
    print $id->uuid()."\n";
}
close(F);
