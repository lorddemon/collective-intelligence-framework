#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Getopt::Std;
use CIF::Client;
use Snort::Rule;
use Regexp::Common qw/net/;
use JSON;

my %opts;
getopts('dhs:f:c:l:t:', \%opts);
die(usage()) if($opts{'h'});

my $feed = $opts{'f'} || shift || 'infrastructure';
my $sid = ($opts{'s'}) || '10000000';
my $c = $opts{'c'} || $ENV{'HOME'}.'/.cif';

sub usage {
    return <<EOF;
Usage: perl $0 -s 1 -f suspicious_networks 
    -h  --help:     this message
    -f  --feed:     type of feed
        
    configuration file ~/.cif should be readable and look something like:

        [client]
        host = https://example.com:443/api
        apikey = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        timeout = 60

Examples:
    \$> perl snort.pl -f infrastructure/cache
    \$> perl snort.pl -f infrastructure/networks/cache > snort_networks.rules

EOF
}

my ($client,$err) = CIF::Client->new({config => $c});
die($err) unless($client);

$client->GET($feed);
die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

my $text = $client->responseContent();

my $hash = from_json($text);
exit 1 unless(exists($hash->{'data'}->{'result'}));
my @a = @{$hash->{'data'}->{'result'}};

my $rules = '';
foreach (@a){
    next unless($_->{'address'} =~ /^$RE{'net'}{'IPv4'}/);
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
    $r->opts('msg',$_->{'restriction'}.' - '.$_->{'description'});
    $r->opts('threshold','type limit,track by_src,count 1,seconds 3600');
    $r->opts('sid',$sid++);
    $r->opts('reference',$_->{'alternativeid'}) if($_->{'alternativeid'});
    $rules .= $r->string()."\n";
}
print $rules;
