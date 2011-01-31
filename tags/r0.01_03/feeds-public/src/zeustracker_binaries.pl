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

my $partner = 'zeustracker.abuse.ch';
my $url = 'https://zeustracker.abuse.ch/monitor.php?urlfeed=binaries';
my $content;
my $rss = XML::RSS->new();

$content = get($url);
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    $_ = $item->{'description'};
    my ($url,$status,$md5) = m/^URL: (\S+), status: (\S+), MD5 hash: (\S+)$/;
    next unless($url);
    my $severity = 'low';
    $severity = 'medium' if(uc($status) eq 'ONLINE');

    my $host = $item->{'title'};
    if($host =~ /^($RE{net}{IPv4})/){
        $host = $1;
    } else {
        $host =~ /^([A-Za-z0-9.-]+\.[a-zA-Z]{2,6})/;
        $host = $1;
    }

    my $detecttime;
    if($item->{title} =~ /\((\d{4}\-\d{2}\-\d{2})\)/){
        $detecttime = DateTime::Format::DateParse->parse_datetime($1);
    }
    $detecttime .= 'Z';

    my $uuid;
    my $impact = 'malware zeus binary';
    if($md5){
        $uuid = CIF::Message::Malware->insert({
            source  => $partner,
            description => $impact.' md5:'.$md5,
            impact      => $impact,
            hash_md5    => $md5,
            restriction => 'need-to-know',
            detecttime  => $detecttime,
            confidence  => 7,
            severity    => 'medium',
            alternativeid  => 'https://zeustracker.abuse.ch/monitor.php?search='.$md5,
            alternativeid_restriction => 'public',
        });
        $uuid = $uuid->uuid();
    }

    $impact = 'malware url zeus binary';
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
        detecttime  => $detecttime,
        alternativeid  => 'https://zeustracker.abuse.ch/monitor.php?host='.$host,
        alternativeid_restriction => 'public',
    });
    warn $uuid;

}
