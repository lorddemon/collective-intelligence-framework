#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;

my %opts;
getopt('hdq:f:c:', \%opts);
die(usage()) if($opts{'h'});

my $query = $opts{'q'} || die(usage());
my $format = $opts{'f'} || 'table';
my $debug = ($opts{'d'}) ? 1 : 0;
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';

sub usage {
    return <<EOF;
Usage: perl $0 -q xyz.com -f table
        -h  --help:                 this message
        -d  --debug:                debug output
        -f  --format [raw|table]:   output format
        -q <string>:                query string (use 'url:<md5|sha1>' for url hash lookups)

    configuration file ~/.cif should be readable and look something like:

    url=https://example.com:443/REST/1.0/cif
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

EOF
}

open(F,$c) || die('could not read configuration file: '.$c.' '.$!);

my ($apikey,$url);
while(<F>){
    my ($o,$v) = split(/=/,$_);
    $url = $v if(lc($o) eq 'url');
    $apikey = $v if(lc($o) eq 'apikey');
}
$url =~ s/\n//;
$apikey =~ s/\n//;
close(F);

$format = 'json' if($format eq 'table');
$format = 'text' if($format eq 'raw');

my $client = CIF::Client->new({ 
    host        => $url,
    timeout     => 10,
    apikey      => $apikey,
    format      => $format,
});

$client->search($query,$format);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

die ('request failed: '.$text) unless($text =~ /^RT.* 200 Ok (\d+)\/\d+ /);
die ('no results found') unless($1 > 0);

my @lines = split(/\n/,$text);

if($format eq 'json'){
    print $client->table($lines[2]);
} else {
    foreach (@lines){
        print $_."\n"
    }
}
