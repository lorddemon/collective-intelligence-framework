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

my $feed = $opts{'f'} || '';
my $debug = ($opts{'d'}) ? 1 : 0;
my $sid = ($opts{'s'}) || '10000000';
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';
my $limit = $opts{'l'} || 5000;
my $timeout = $opts{'t'} || 30;
sub usage {
    return <<EOF;
Usage: perl $0 -s 1 -f suspicious_networks 
        -h  --help:     this message
        -d  --debug:    debug output
        -f  --feed:     type of feed
        -l  --limit:    feed limit
        
        configuration file ~/.cif should be readable and look something like:

    url=https://example.com:443/REST/1.0/cif
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

Examples:
    \$> perl snort.pl -f infrastructure/impact/botnet
    \$> perl snort.pl -s 5000 -f suspicious_networks
    \$> perl snort.pl -s 50000 infrastructure/impact/malware

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
    format      => 'json',
});

$client->GET('/feeds/inet/'.$feed.'?apikey='.$client->apikey().'&format=json&qlimit='.$limit.'&feedlimit='.$limit);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

die ('request failed: '.$text) unless($text =~ /^RT.* 200 Ok (\d+)\/\d+ /);
die ('no results found') unless($1 > 0);

my @lines = split(/\n/,$text);

my @a = @{from_json($lines[2])};

my $rules = '';
foreach (@a){
    my $portlist = ($_->{'portlist'} eq 'NA') ? 'any' : $_->{'portlist'};
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
    $r->opts('reference',$url.'/search/'.$_->{'address'});
    $rules .= $r->string()."\n";
}
print $rules;
