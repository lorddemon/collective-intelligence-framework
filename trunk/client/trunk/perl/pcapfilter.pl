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

my $feed = $opts{'f'} || shift || 'infrastructure';
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';

sub usage {
    return <<EOF;
Usage: perl $0 -f infrastructure
        -h  --help:     this message
        -f  --feed:     type of feed
        
    configuration file ~/.cif should be readable and look something like:

        [client]
        host = https://example.com:443/REST/1.0/cif
        apikey = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        timeout = 60

Examples:
    \$> perl $0 -f infrastructure > suspicious.filter
    \$> perl $0 -f infrastructure\/cache

EOF
}

my $client = CIF::Client->new({ config => $c});

$client->GET($feed);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
exit 1 unless(exists($hash->{'data'}->{'result'}));
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
