#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use CIF::FeedParser;
use Config::Simple;
use Data::Dumper;
use Net::DNS::Resolver;

my %opts;
getopts('dFc:f:',\%opts);
my $debug = $opts{'d'};
my $full_load = $opts{'F'} || 0;
my $config = $opts{'c'} || $ENV{'HOME'}.'/.cif';
my $f = $opts{'f'} || die('missing feed');
my $c = Config::Simple->new($config) || die($!.' '.$config);
$c = $c->param(-block => $f);

my $nsres;
unless($full_load){
    $c->{nsres} = Net::DNS::Resolver->new(recursive => 0);
}

my @lines = CIF::FeedParser::parse($c);
my @recs;
my $x = 15;
foreach (@lines){
    my %h = %{$c};
    my @cols = split(/,/,$c->{'regex_values'});
    my @vals = @{$_};
    foreach my $x (0 ... $#cols){
        my $col = $cols[$x];
        $h{$col} = $vals[$x];
    }
    push(@recs,\%h);
}

CIF::FeedParser::insert($full_load,@recs);
