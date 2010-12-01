#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;

use CIF::Message::InfrastructureSimple;

my $site_ref = 'http://www.spamhaus.org/sbl/sbl.lasso?query=';
my $dt = DateTime->from_epoch(epoch => time());
my $content = get('http://www.spamhaus.org/drop/drop.lasso') || die $!;
my @lines = split(/\n/,$content);

foreach (@lines){
    next if($_ =~ /^;/);
    next if($_ =~ /^\n/);
    my ($addr,$ref) = split(/ \; /,$_);
	$addr =~ s/(\n|\s+)//;
    $ref =~ s/\n$//;

    my $id = $ref;

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00';

    warn CIF::Message::InfrastructureSimple->insert({
        address     => $addr,
        source      => 'spamhaus.org',
        description => 'hijacked network infrastructure '.$addr,
        impact      => 'hijacked network infrastructure',
        confidence  => 7,
        severity    => 'high',
        sourceid     => $ref,
        restriction => 'need-to-know',
        alternativeid  => $site_ref.$ref,
        alternativeid_restriction => 'public',
        detecttime  => $detecttime,
    });
}
