#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use CIF::Client;

my %opts;
getopt('hdq:f:c:', \%opts);
die(usage()) if($opts{'h'});

my $query = $opts{'q'} || die(usage());
my $format = $opts{'f'} || 'table';
my $debug = ($opts{'d'}) ? 1 : 0;
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';
my $ref_url = 'https://example.com/Lookup.html?q=';

sub usage {
    return <<EOF;
Usage: perl $0 -q xyz.com -f table
        -h  --help:                 this message
        -d  --debug:                debug output
        -q <string>:                query string (use 'url:<md5|sha1>' for url hash lookups)

    configuration file ~/.cif should be readable and look something like:

    url=https://example.com:443/api
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

my $client = CIF::Client->new({ 
    host    => $url,
    timeout => 60,
    apikey  => $apikey,
});

$client->search($query);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

print $client->table($text) || die('no records');
