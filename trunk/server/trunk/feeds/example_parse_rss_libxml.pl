#!/usr/bin/perl -w

use strict;

use XML::RSS;
use XML::LibXML;
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
    next unless($item->{'description'});
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(string => $item->{'description'});
    my @nodes = $doc->findnodes('//Incident');
    my $a = $nodes[0]->findvalue('./EventData/Flow/System/Node/Address');
    my $ref = $item->{'link'};
    my @ids = $nodes[0]->findnodes('./IncidentID');
    my $source = $ids[0]->getAttribute('name');
    my $r = $nodes[0]->getAttribute('restriction');

    ## BE CAREFUL ##
    ## IF YOUR ADDRESSES COULD HAVE COMMA'S OR OTHER DELIMS IN THEM
    ## NOWS A GOOD TIME TO RE-ENCODE THEM =)

    print "$ref,$source,$a,$r\n";
}

