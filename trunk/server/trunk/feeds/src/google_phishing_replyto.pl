#!/usr/bin/perl -w

use strict;

use LWP::Simple;
use CIF::Message::Email;

my $feed = 'http://aper.svn.sourceforge.net/svnroot/aper/phishing_reply_addresses';
my $hash = {
    source                      => $feed,
    impact                      => 'phishing replyto',
    restriction                 => 'need-to-know',
    confidence                  => 3,
    severity                    => 'medium',
    alternativeid               => $feed,
    alternativeid_restriction   => 'public',
};

my $content = get($feed) || die ('unable to download url: '.$feed);

my @lines = split(/\n/,$content);
foreach my $line (@lines){
    next if($line =~ /^#/);
    my ($address,$type,$date) = split(/,/,$line);
    my ($id,$err) = CIF::Message::Email->insert({
        %$hash,
        address         => $address,
        description     => $hash->{'impact'}.' '.$address,
        detecttime      => $date,
    });
    warn $id if($id);
    die($err) if($err);
}
