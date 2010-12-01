#!/usr/bin/perl -w

use strict;

use LWP::Simple;
use XML::RSS;
use DateTime::Format::DateParse;
use Net::DNS;
use CIF::Message::DomainSimple;
use Data::Dumper;

my $url         = 'http://hosts-file.net/rss.asp';
my $partner     = 'hosts-file.net';
my $restriction = 'need-to-know';
my $confidence  = 5;
my $severity    = 'low';
my $impact      = 'malicious domain';

my $res = Net::DNS::Resolver->new(
    nameservers => ['8.8.8.8'],
);

my $content = get($url) || die($!);
my $rss = XML::RSS->new();
$rss->parse($content);
my $x = 0;
foreach (@{$rss->{'items'}}){
    
    my ($domain,$aid,$dt) = ($_->{'title'},$_->{'permaLink'},$_->{'pubDate'});
    $dt = DateTime::Format::DateParse->parse_datetime($dt);
    $_ = $_->{'description'};
    m/ (EMD|EXP|FSA|HJK) /;
    next unless($1);

    my $id = CIF::Message::DomainSimple->insert({
        nsres       => $res,
        address     => $domain,
        restriction => $restriction,
        detecttime  => $dt,
        severity    => $severity,
        confidence  => $confidence,
        impact      => $impact,
        description => $impact.' '.$domain,
        source      => $partner,
        alternativeid   => $aid,
        alternativeid_restriction => 'public',
    });
    warn $id;
}
