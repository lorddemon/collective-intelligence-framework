#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;
use JSON;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

my %opts;
getopts('dhs:f:c:', \%opts);
die(usage()) if($opts{'h'});

my $feed = $opts{'f'} || 'infrastructure';
my $debug = ($opts{'d'}) ? 1 : 0;
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';

sub usage {
    return <<EOF;
Usage: perl $0 -s 1 -f suspicious_networks 
        -h  --help:     this message
        -d  --debug:    debug output
        -f  --feed:     type of feed
        
        configuration file ~/.cif should be readable and look something like:

    url=https://example.com:443/REST/1.0/cif
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

Examples:
    \$> perl $0 -f infrastructure > suspicious.filter

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
    host        => $url,
    timeout     => 60,
    apikey      => $apikey,
});

$client->GET('/'.$feed.'?apikey='.$client->apikey());
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
my @a = @{$hash->{'data'}->{'result'}};

my $filter = '';
foreach (@a){
    my $address = $_->{'address'};
    if($address =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/){
        $filter .= "net $address or ";
    } else {
        $filter .= "host $address or ";
    }
}
$filter =~ s/ or $//;
print $filter;
