#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;
use JSON;

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

    url=https://example.com:443/api
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

Examples:
    \$> perl $0 -f infrastructure

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
    timeout     => 10,
    apikey      => $apikey,
    format      => 'json',
});

$client->GET('/'.$feed.'?apikey='.$client->apikey());
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
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
