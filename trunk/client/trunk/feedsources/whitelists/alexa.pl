#!/usr/bin/perl -w

use CIF::Message::DomainWhitelist;
use DateTime;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use LWP::Simple;

my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T00:00:00Z';
my $limit = 5;

my $file = '/tmp/top-1m.csv.zip';
my $url = 'http://s3.amazonaws.com/alexa-static/top-1m.csv.zip';
my $content = get($url);
open(F,'>',$file);
print F $content;
close(F);

my $unzipped;
unzip $file => \$unzipped, Name => 'top-1m.csv' || die('unzip failed: '.$UnzipError);
my @lines = split(/\n/,$unzipped);

foreach (0 ... ($limit-1)){
    my $line = $lines[$_];
    my ($rank,$address) = split(/,/,$line);
    my $id = CIF::Message::DomainWhitelist->insert({
        source     => 'alexa.com',
        impact      => 'domain whitelist',
        description => 'domain whitelist alexa.com #'.$rank.' '.$address,
        address     => $address,
        confidence  => 7,
        detecttime  => $date,
        restriction => 'need-to-know',
        alternativeid   => 'http://www.alexa.com/siteinfo/'.$address,
        alternativeid_restriction   => 'public',
    });
    warn $id;
}
