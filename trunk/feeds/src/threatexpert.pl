#!/usr/bin/perl -w

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;

use CIF::Message::Malware;

my $partner = 'threatexpert.com';
my $url = 'http://www.threatexpert.com/latest_threat_reports.aspx';
my $content;
my $rss = XML::RSS->new();

$content = get($url);
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    my $date = $item->{'pubDate'};
    my $link = $item->{'link'};
    my $title = $item->{'title'};
    my $severity = 'medium';
    $link =~ m/md5=([a-f0-9]{32})$/;
    my $md5 = $1;

    my $detecttime;
    $detecttime = DateTime::Format::DateParse->parse_datetime($date);
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $uuid;
    my $impact = 'malware binary';
    my $description = $impact.' md5:'.$md5.' '.$title;
    if($md5){
        $uuid = CIF::Message::Malware->insert({
            source  => $partner,
            description => $description,
            impact      => $impact,
            hash_md5    => $md5,
            restriction => 'need-to-know',
            detecttime  => $detecttime,
            confidence  => 7,
            severity    => $severity,
            alternativeid  => $link,
            alternativeid_restriction => 'public',
        });
        $uuid = $uuid->uuid();
    }

    warn $uuid;

}
