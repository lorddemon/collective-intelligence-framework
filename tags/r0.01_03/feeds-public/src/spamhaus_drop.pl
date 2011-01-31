#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;

use CIF::Message::InfrastructureSimple;

my $feed = 'http://www.spamhaus.org/drop/drop.lasso';
my $dt = DateTime->from_epoch(epoch => time());
$dt = $dt->ymd().'T00:00:00Z';
my $hash = {
    source                      => 'spamhaus.org',
    restriction                 => 'need-to-know',
    description                 => 'hijacked network infrastructure',
    impact                      => 'hijacked network infrastructure',
    confidence                  => 9,
    severity                    => 'high',
    alternativeid               => 'http://www.spamhaus.org/sbl/sbl.lasso?query=',
    alternativeid_restriction   => 'public',
    detecttime                  => $dt,
};


my $content = get($feed) || die $!;
my @lines = split(/\n/,$content);

foreach (@lines){
    next if($_ =~ /^;/);
    next if($_ =~ /^\n/);
    my ($addr,$ref) = split(/ \; /,$_);
	$addr =~ s/(\n|\s+)//;
    $ref =~ s/\n$//;

    my %info = %$hash;
    $info{'description'}    = $info{'description'}.' '.$addr;
    $info{'address'}        = $addr;
    $info{'alternativeid'}  = $info{'alternativeid'}.$ref;
    my ($id,$err) = CIF::Message::InfrastructureSimple->insert({%info});
    warn $id;
    die($err) if($err);
}
