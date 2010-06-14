#!/usr/bin/perl -w

use strict;

use CIF::Message::SuspiciousNetwork;
use Data::Dumper;
use Text::Table;

my @recs = CIF::Message::SuspiciousNetwork->search_history_byreporttime("2010-06-01");

my $h;
my $as;
my $cidr;

foreach my $r (@recs){
    my $key = $r->address();
    next if(exists($h->{$key}));
    $h->{$key} = $r;
    $h->{$key}->{'cidr'} = $r->cidr();
    $h->{$key}->{'asn'} = $r->asn();
}

foreach my $a (keys %$h){
    next unless($h->{$a}->{'asn'});
    my $asn = $h->{$a}->{'asn'};
    $as->{$asn}->{'count'} += 1;
    $as->{$asn}->{'desc'} = $h->{$a}->asn_desc();
}

my @sort = sort { $as->{$b}->{'count'} <=> $as->{$a}->{'count'} } keys %$as;

my $t = Text::Table->new(
    "ratio", { is_sep => 1, title => ' | ' },
    "count", { is_sep => 1, title => ' | ' },
    "asn", { is_sep => 1, title => ' | ' },
    "asn_desc",
);

foreach my $x (@sort){
    my $ratio = ($as->{$x}->{'count'} / $#sort);
    $t->load([
        $ratio,
        $as->{$x}->{'count'},
        $x,
        $as->{$x}->{'desc'},
    ]);
}

print $t;
