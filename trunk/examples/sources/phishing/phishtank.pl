#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use threads;
use threads::shared;
use XML::LibXML 1.70 qw(:threads_shared);
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);

use CIF::Message::PhishingURL;
use CIF::Message::Infrastructure;
use CIF::Message::InetWhitelist;
use CIF::Message::Inet;

my %opts;
getopt('pf:k:d', \%opts);
my $apikey = $opts{'k'} || die('missing apikey');
my $download = $opts{'d'} || 0;
my $cache = $opts{'f'} || '/tmp/phishtank.xml';
my $keepcache = $opts{'c'} || 0;
my $oldest = DateTime::Format::DateParse->parse_datetime($opts{'t'}) || DateTime->from_epoch(epoch => (time() - (7*84600)));

my $url = "http://data.phishtank.com/data/$apikey/online-valid.xml";

if(! -e $cache || $download){
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

unless($keepcache){
    system('rm '.$cache);
}

my $x = 0;
my @nodes = $doc->findnodes('//entry');
warn 'inserting '.$#nodes.'+ nodes';
foreach (@nodes){
    my $node = $_;
    my $created = DateTime::Format::DateParse->parse_datetime($node->findvalue('./submission/submission_time'));
    next if($created->epoch() < $oldest->epoch());
    my $key = $node->findvalue('./url');
    my $status = $node->findvalue('./status/online');
    my $target = $node->findvalue('./target');
    my $severity = ($status eq 'yes') ? 'medium' : 'low';

    my $id = $node->findvalue('./phish_id');
    my $did = $node->findvalue('./phish_detail_url');

    my @address = $node->findnodes('./details/detail/ip_address');
    
    my $uuid = CIF::Message::PhishingURL->insert({
        address     => $key,
        impact      => 'phishing url',
        source      => 'phishtank.com',
        description => 'phishing url target:'.$target.' md5:'.md5_hex($key),
        severity    => $severity,
        confidence  => 7,
        restriction => 'need-to-know',
        detecttime  => $created,
        alternativeid  => $did,
        alternativeid_restriction => 'public',
    });

    foreach (@address){
        $_ = $_->textContent();
        next if(CIF::Message::Inet::isPrivateAddress($_) || CIF::Message::InetWhitelist::isWhitelisted($_));
        my ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Inet::asninfo($_);
        CIF::Message::Infrastructure->insert({
            address     => $_,
            source      => 'phishtank.com',
            relatedid   => $uuid->uuid(),
            impact      => 'phishing infrastructure',
            description => 'phishing infrastructure target:'.$target.' - '.$_,
            severity    => 'low',
            confidence  => 5,
            restriction => 'public',
            detecttime  => $created,
            asn         => $as,
            cidr        => $network,
            rir         => $rir,
            cc          => $ccode,
            asn_desc    => $as_desc,
            alternativeid  => $did,
            alternativeid_restriction => 'public',
        });
    }
    warn $uuid;
}
