#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;
use Snort::Rule;
use JSON;

my %opts;
getopts('dhs:f:c:l:t:', \%opts);
die(usage()) if($opts{'h'});

my $feed = $opts{'f'} || 'infrastructure';
my $debug = ($opts{'d'}) ? 1 : 0;
my $sid = ($opts{'s'}) || '10000000';
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';
my $timeout = $opts{'t'} || 60;
my $ref_url = 'https://example.com/Lookup.html?q=';

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
    \$> perl snort.pl -f infrastructure
    \$> perl snort.pl -f infrastructure/networks > snort_networks.rules

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
    timeout     => $timeout,
    apikey      => $apikey,
});

$client->GET('/'.$feed.'?apikey='.$client->apikey());
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
my @a = @{$hash->{'data'}->{'result'}};
exit 1 unless($#a);

my $rules = '';
foreach (@a){
    my $portlist = ($_->{'portlist'}) ? 'any' : $_->{'portlist'};
    my $r = Snort::Rule->new(
        -action => 'alert',
        -proto  => 'ip',
        -src    => 'any',
        -sport  => 'any',
        -dst    => $_->{'address'},
        -dport  => $portlist,
        -dir    => '->',
    );
    $r->opts('msg',$_->{'restriction'}.' - '.$_->{'impact'});
    $r->opts('threshold','type limit,track by_src,count 1,seconds 3600');
    $r->opts('sid',$sid++);
    $r->opts('reference',$ref_url.$_->{'address'});
    $rules .= $r->string()."\n";
}
print $rules;
