#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use CIF::Message::InfrastructureSimple;
use CIF::Message::Infrastructure;
use LWP::Simple;

my $url = 'http://maliciousnetworks.org/fire-blocklist.txt';
my $dt = DateTime->from_epoch(epoch => time());
$dt = $dt->ymd().'T00:00:00Z';

my $hash = {
        source      => 'maliciousnetworks.org',
        impact      => 'suspicious address',
        confidence  => 3,
        severity    => 'medium',
        restriction => 'need-to-know',
        alternativeid  => 'http://maliciousnetworks.org/ipinfo.php?as=',
        alternativeid_restriction => 'public',
        detecttime  => $dt,
};

my $content = get($url) || die('failed to get url: '.$!);
my @lines = split(/\n/,$content);

foreach (@lines){
    next if(/^#/);
    next if(/^$/);
    next if(/^\r/);
    my ($addr,$asn) = split(/\s+/,$_);

    my %info = %$hash;  
    $info{'alternativeid'} = $info{'alternativeid'}.$asn;
    $info{'address'} = $addr;
    $info{'description'} = $info{'impact'}.' '.$addr;
    my ($id,$err) = CIF::Message::InfrastructureSimple->insert({%info});
    die($err) if($err);
    warn $id;
}
