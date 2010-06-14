#!/usr/bin/perl -w

use strict;

use CIF::Message::PhishingURL;
use XML::RSS;
use CIF::Message::Structured;

my $hash;
my @recs = CIF::Message::PhishingURL->search_history_byreporttime("2010-06-01 00:00:00Z");


foreach my $rec (@recs){
    my $key = $rec->url_sha1();
    next if(exists($hash->{$key}));
    $hash->{$key} = $rec;
    $hash->{$key}->{'confidence'} = $rec->confidence();
}

my $rss = new XML::RSS (version => '1.0');
$rss->channel(
    title   => 'example CIF feed',
    link    => 'example.com',
    description => "example CIF feed",
    generator   => 'my cif engine v0.00_00',
    syn         => {
        updatePeriod    => "hourly",
        updateFrequency => "4",
        updateBase      => "1901-01-01T00:00+00:00",
    },
);

my $x = 0;
foreach my $h (keys %$hash){
    my $r = $hash->{$h};
    my $m = CIF::Message::Structured->retrieve(uuid => $r->uuid()) || undef;
    $m = $m->message() if($m);
    $rss->add_item(
        title   => $r->restriction().','.$r->description(),
        link   => 'example.com/messages/'.$r->uuid(),
        guid    => $r->uuid(),
        category    => 'phishing url',
        description => $m,
        dc      => {
            creator => $r->source(),
            date    => $r->reporttime(),
        },
    );
    last if $x++ == 3;
}

print $rss->as_string();
