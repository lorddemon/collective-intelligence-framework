#!/usr/bin/perl -w

use strict;

use XML::LibXML;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);

use CIF::Message::PhishingURL;
use CIF::Message::Infrastructure;

my $cache = "/tmp/phishtank.xml";

my $apikey = 'GET YOUR OWN KEY FROM phishtank.com!!!';

my $url = "http://data.phishtank.com/data/$apikey/online-valid.xml";

if(! -e $cache || shift){
    warn 'pulling xml from: '.$url;
    my $content = get($url);

    warn 'xml downloaded';
    open(F,">$cache");
    print F ($content);
    close(F);
}

my $parser = XML::LibXML->new();

open(my $fh, $cache);
binmode $fh;
my $doc = $parser->parse_fh($fh);

close($fh);
my $x = 0;
my @nodes = $doc->findnodes('//entry');
my $hash;
foreach my $node (@nodes){
    my $key = $node->findvalue('./url');
    my $created = DateTime::Format::DateParse->parse_datetime($node->findvalue('./submission/submission_time'));
    my $status = $node->findvalue('./status/online');
    my $severity = ($status eq 'yes') ? 'medium' : 'low';

    my $id = $node->findvalue('./phish_id');
    my $did = $node->findvalue('./phish_detail_url');

    my $address = $node->findvalue('./details/detail/ip_address');
    my $asn     = $node->findvalue('./details/detail/announcing_network');
    my $cidr    = $node->findvalue('./details/detail/cidr_block');
    my $rir     = $node->findvalue('./details/detail/rir');

    my $uuid = CIF::Message::PhishingURL->insert({
        address     => $key,
        impact      => 'phishing url',
        source      => 'phishtank.com',
        description => 'phishing url md5:'.md5_hex($key),
        severity    => $severity,
        confidence  => 7,
        restriction => 'need-to-know',
        reporttime  => $created,
        externalid  => $did,
        externalid_restriction => 'public',
    });

    CIF::Message::Infrastructure->insert({
        address     => $address,
        source      => 'phishtank.com',
        relatedid   => $uuid->uuid(),
        impact      => 'phishing infrastructure',
        description => 'phishing infrastructure - '.$address,
        severity    => 'low',
        confidence  => 5,
        restriction => 'public',
        reporttime  => $created,
        asn         => $asn,
        cidr        => $cidr,
        rir         => $rir,
        externalid  => $did,
        externalid_restriction => 'public',
    });
    warn $uuid->uuid();
}
