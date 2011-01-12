#!/usr/bin/perl -w

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use Regexp::Common qw/net/;
use DateTime::Format::DateParse;
use DateTime;
use Digest::MD5 qw(md5_hex);

use CIF::Message::Malware;
use CIF::Message::UrlMalware;
use CIF::Message::InfrastructureSimple;
use CIF::Message::DomainSimple;

my $partner = 'malc0de.com';
my $url = 'http://malc0de.com/rss/';
my $ref = 'http://malc0de.com/database/index.php?search=';

my $content;
my $dt = DateTime->from_epoch(epoch => time());
$dt = $dt->ymd().'T00:00:00Z';
my $rss = XML::RSS->new();

$content = get($url);
$rss->parse($content);


foreach my $item (@{$rss->{items}}){
    $_ = $item->{'description'};
    my ($url,$ip,$cc,$asn,$md5) = m/^URL: (\S+), IP Address: (\S+), Country: (\S+), ASN: (\S+), MD5: (\S+)$/;

    next unless($url);
    my $severity = 'medium';

    my $host = $item->{'title'};
    if($host =~ /^($RE{net}{IPv4})/){
        $host = $1;
    } else {
        $host =~ /^([A-Za-z0-9.-]+\.[a-zA-Z]{2,6})/;
        $host = $1;
    }

    my $impact = 'malware url';

    my $uuid;
    if($md5){
        $uuid = CIF::Message::Malware->insert({
            source  => $partner,
            description => $impact.' md5:'.$md5,
            impact      => $impact,
            hash_md5    => $md5,
            restriction => 'need-to-know',
            detecttime  => $dt,
            confidence  => 7,
            severity    => $severity,
            alternativeid  => $ref.$md5.'&MD5=on',
            alternativeid_restriction => 'public',
        });
        $uuid = $uuid->uuid();
    }

    $uuid = CIF::Message::UrlMalware->insert({
        address     => $url,
        source      => $partner,
        relatedid   => $uuid,
        impact      => $impact,
        description => $impact.' md5:'.md5_hex($url),
        confidence  => 7,
        malware_md5 => $md5,
        severity    => $severity,
        restriction => 'need-to-know',
        detecttime  => $dt,
        alternativeid  => $ref.$host,
        alternativeid_restriction => 'public',
    });

    if($ip){
        CIF::Message::InfrastructureSimple->insert({
            address     => $ip,
            source      => $partner,
            relatedid   => $uuid->uuid(),
            impact      => 'malware infrastructure',
            description => 'malware infrastructure '.$host,
            confidence  => 5,
            severity    => 'low',
            restriction => 'need-to-know',
            detecttime  => $dt,
            alternativeid  => $ref.$host,
            alternativeid_restriction => 'public',
        });
    }
    if($host){
        CIF::Message::DomainSimple->insert({
            address     => $host,
            source      => $partner,
            relatedid   => $uuid->uuid(),
            impact      => 'malware domain',
            description => 'malware domain '.$host,
            confidence  => 5,
            severity    => 'low',
            restriction => 'need-to-know',
            detecttime  => $dt,
            alternativeid  => $ref.$host,
            alternativeid_restriction => 'public',
        });
    }
    warn $uuid;
}
