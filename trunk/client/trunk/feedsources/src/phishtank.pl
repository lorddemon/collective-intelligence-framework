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
use Unicode::String qw/utf8/;

use CIF::Message::URLPhishing;
use CIF::Message::InfrastructureSimple;

my %opts;
getopt('pf:k:d', \%opts);
my $apikey = $opts{'k'};
my $download = $opts{'d'} || 0;
my $cache = $opts{'f'} || '/tmp/phishtank.xml';
my $keepcache = $opts{'c'} || 1;
my $oldest = DateTime::Format::DateParse->parse_datetime($opts{'t'}) || DateTime->from_epoch(epoch => (time() - (7*84600)));

if(! -e $cache || $download){
    die('missing apikey') unless($apikey);
    my $url = "http://data.phishtank.com/data/$apikey/online-valid.xml";
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
#    next if($created->epoch() < $oldest->epoch());
    my $key = $node->findvalue('./url');
    my $status = $node->findvalue('./status/online');
    my $target = $node->findvalue('./target');
    my $severity = ($status eq 'yes') ? 'medium' : 'low';

    my $id = $node->findvalue('./phish_id');
    my $did = $node->findvalue('./phish_detail_url');

    my @address = $node->findnodes('./details/detail/ip_address');
    
    $key = utf8($key);
    $key = $key->utf8();
    my $uuid = CIF::Message::URLPhishing->insert({
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
        CIF::Message::InfrastructureSimple->insert({
            address     => $_,
            source      => 'phishtank.com',
            relatedid   => $uuid->uuid(),
            impact      => 'phishing infrastructure',
            description => 'phishing infrastructure target:'.$target.' '.$_,
            severity    => 'low',
            confidence  => 5,
            restriction => 'public',
            detecttime  => $created,
            alternativeid  => $did,
            alternativeid_restriction => 'public',
        });
    }
    warn $uuid;
}
