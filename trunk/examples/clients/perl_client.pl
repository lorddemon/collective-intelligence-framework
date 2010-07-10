#!/usr/bin/perl -w

use strict;

use REST::Client;
use Text::Table;
use JSON;
use Data::Dumper;
use Getopt::Std;

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

my $client = REST::Client->new({ timeout => 10 });

my $text = search($query,$format);

die ('request failed with response code: '.$client->responseCode()) unless($text =~ /^RT.* 200 Ok (\d+)\/\d+ /);
die ('no results found') unless($1 > 0);

my @lines = split(/\n/,$text);

if($format eq 'json'){
    my @a = @{from_json($lines[2])};
    
    my @cols = (
        'restriction',  { is_sep => 1, title => '|', },
        'impact',       { is_sep => 1, title => '|', },
        'description',  { is_sep => 1, title => '|', },
        'detecttime',   { is_sep => 1, title => '|', },
        'reference'
    );

    # test to see if 'address' key is in here
    if(exists($a[0]->{'address'})){ 
        push(@cols,{ is_sep => 1, title => '|' },'address');
    }
    my $table = Text::Table->new(@cols);

    foreach (@a){
        if(exists($_->{'address'})){
            $table->load([
                $_->{'restriction'},
                $_->{'impact'},
                $_->{'description'},
                $_->{'detecttime'},
                $_->{'reference'},
                $_->{'address'},
            ]);
       } else {
            $table->load([
                $_->{'restriction'},
                $_->{'impact'},
                $_->{'description'},
                $_->{'detecttime'},
                $_->{'reference'}
            ]);
        }
    }
    print $table."\n";
} else {
    foreach (@lines){
        print $_."\n"
    }
}

sub search {
    my ($q,$fmt) = @_;

    my $type;
    for($q){
        if(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/){
            $type = 'inet';
            last;
        }
        if(/^\d+$/){
            $type = 'asn';
            last;
        }
        if(/\w+@\w+/){
            $type = 'email';
            last;
        }
        if(/\w+\.\w+/){
            $type = 'domain';
            last;
        }
        if(/^[a-fA-F0-9]{32,40}$/){
            $type = 'malware';
            last;
        }
        if(/^url:([a-fA-F0-9]{32,40})$/){
            $type = 'url';
            $q = $1;
            last;
        }
    }

    my $s = $url.'/search/'.$type.'/'.$q.'?apikey='.$apikey.'&format='.$fmt;
    print 'DEBUG: '.$s."\n" if($debug);
    $client->GET($s);
    print 'DEBUG: '.$client->responseCode()."\n" if($debug);
    return ($client->responseContent());
}

