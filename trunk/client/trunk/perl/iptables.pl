#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;
use JSON;

my %opts;
getopts('hf:c:', \%opts);
die(usage()) if($opts{'h'});

my $feed = $opts{'f'} || shift || 'infrastructure';
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';

sub usage {
    return <<EOF;
Usage: perl $0 -f suspicious_networks 
    -h  --help:     this message
    -f  --feed:     type of feed
        
    configuration file ~/.cif should be readable and look something like:

    [client]
    host = https://example.com:443/api
    apikey = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    timeout = 60

Examples:
    \$> perl $0 -f infrastructure/cache
    \$> perl $0 -f infrastructure/networks/cache

EOF
}

my $client = CIF::Client->new({config => $c});

$client->GET($feed);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
exit 1 unless(exists($hash->{'data'}->{'result'}));
my @a = @{$hash->{'data'}->{'result'}};

my $rules = "iptables -N CIF_IN\n";
$rules .= "iptables -F CIF_IN\n";
$rules .= "iptables -N CIF_OUT\n";
$rules .= "iptables -F CIF_OUT\n";
foreach (@a){
    $rules .= "iptables -A CIF_IN -s $_->{'address'} -j DROP\n";
    $rules .= "iptables -A CIF_OUT -d $_->{'address'} -j DROP\n";

}
$rules .= "iptables -A INPUT -j CIF_IN\n";
$rules .= "iptables -A CIF_IN -j LOG --log-level 6 --log-prefix '[IPTABLES] cif dropped'\n";
$rules .= "iptables -A OUTPUT -j CIF_OUT\n";
$rules .= "iptables -A CIF_OUT -j LOG --log-level 6 --log-prefix '[IPTABLES cif dropped'\n";
print $rules."\n";
