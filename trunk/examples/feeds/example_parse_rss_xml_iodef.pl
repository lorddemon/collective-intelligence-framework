#!/usr/bin/perl -w

use strict;

use XML::RSS;
use XML::IODEF;
use LWP::Simple;
my $url = '';

my $rss = XML::RSS->new();
my $content = '';
if($url){
    $content = get($url);
} else {
    while(<STDIN>){
        $content .= $_;
    }
}

die "no content to parse" unless($content);

$rss->parse($content);

print "# link,source,address,restriction\n";
foreach my $item (@{$rss->{items}}){
    my $xml = XML::IODEF->new();
    $xml->in($item->{'description'}) || next();
    my $a = $xml->get('IncidentEventDataFlowSystemNodeAddress');
    my $r = $xml->get('Incidentrestriction');
    my $source = $xml->get('IncidentIncidentIDname');
    my $ref = $item->{'link'};

    ## BE CAREFUL ##
    ## IF YOUR ADDRESSES COULD HAVE COMMA'S OR OTHER DELIMS IN THEM
    ## NOWS A GOOD TIME TO RE-ENCODE THEM =)

    print "$ref,$source,$a,$r\n";
}

