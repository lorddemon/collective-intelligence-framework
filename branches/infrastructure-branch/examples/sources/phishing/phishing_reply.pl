#!/usr/bin/perl -w

use strict;

use LWP::Simple;
use CIF::Message::Email;

my $url = 'http://aper.svn.sourceforge.net/svnroot/aper/phishing_reply_addresses';

my $content = get($url) || die ('unable to download url: '.$url);

my @lines = split(/\n/,$content);
foreach my $line (@lines){
    next if($line =~ /^#/);
    my ($address,$type,$date) = split(/,/,$line);
    warn CIF::Message::Email->insert({
        source          => $url,
        address         => $address,
        impact          => 'phishing replyto',
        description     => 'phishing replyto - '.$address,
        restriction     => 'need-to-know',
        confidence      => 3,
        severity        => 'low',
        alternativeid      => $url,
        detecttime      => $date,
        alternativeid_restriction => 'public',
    });
}
