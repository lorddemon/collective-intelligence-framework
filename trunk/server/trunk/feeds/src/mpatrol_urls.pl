#!/usr/bin/perl -w

use strict;

use XML::LibXML 1.70 qw(:threads_shared);
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);
use Unicode::String qw/utf8/;

use CIF::Message::UrlMalware;

my $feed = 'http://www.malware.com.br/cgi/submit?action=list_xml';

my $parser = XML::LibXML->new();
my $xml = get($feed) || die('failed to get feed: '.$!);
my $doc = $parser->load_xml(string => $xml);

my $x = 0;
my @nodes = $doc->findnodes('//url');
warn 'inserting '.$#nodes.'+ nodes';
foreach (@nodes){
    my $node = $_;

    my $id = $node->findvalue('./id');
    my $url = $node->findvalue('./uri');
    my $reported = DateTime::Format::DateParse->parse_datetime($node->findvalue('./date'));
    my $desc = $node->findvalue('./av_info');
    
    $url = utf8($url);
    $url = $url->utf8();

    my $uuid = CIF::Message::UrlMalware->insert({
        address     => $url,
        impact      => 'malware url',
        source      => 'malware.com.br',
        description => 'malware url '.$desc,
        severity    => 'medium',
        confidence  => 5,
        restriction => 'need-to-know',
        detecttime  => $reported,
        alternativeid  => 'http://www.malware.com.br/cgi/search.pl?id='.$id,
        alternativeid_restriction => 'public',
    });
    warn $uuid;
}
