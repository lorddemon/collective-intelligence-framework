#!/usr/bin/perl -w

use strict;

use XML::LibXML 1.70 qw(:threads_shared);
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);
use Unicode::String qw/utf8/;
use Getopt::Std;
use Net::DNS::Resolver;

use CIF::Message::UrlMalware;
use CIF::Message::DomainSimple;

my %opts;
getopts('Fd',\%opts);
my $full_load = $opts{'F'};
my $debug = $opts{'d'};
my $goback = ($full_load) ? undef : DateTime->from_epoch(epoch => (time() - 84600));
$goback = $goback->ymd().'T'.$goback->hms().'Z' if($goback);

my $feed = 'http://www.malware.com.br/cgi/submit?action=list_xml';
my $partner = 'malware.com.br';

my $parser = XML::LibXML->new();
my $xml = get($feed) || die('failed to get feed: '.$!);
my $doc = $parser->load_xml(string => $xml);

my $x = 0;
my @nodes = $doc->findnodes('//url');
warn 'inserting '.$#nodes.'+ nodes' if($debug);
my $hash;
foreach (@nodes){
    my $node = $_;

    my $id = $node->findvalue('./id');
    my $url = $node->findvalue('./uri');
    my $reported = $node->findvalue('./date');

    $reported =~ s/UTC$//;
    $reported =~ m/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/;
    my ($year,$month,$day,$hour,$min,$sec) = ($1,$2,$3,$4,$5,$6);
    $reported = $year.'-'.$month.'-'.$day.'T'.$hour.':'.$min.':'.$sec.'Z';

    my $desc = $node->findvalue('./av_info');
    
    $url = utf8($url);
    $url = $url->utf8();

    my $h = {
        detecttime  => $reported,
        address     => $url,
        description => $desc,
    };
    $hash->{$id} = $h;
}

my @sorted = sort { $hash->{$b}->{'detecttime'} cmp $hash->{$a}->{'detecttime'} } keys %$hash;

foreach (@sorted){
    my $h = $hash->{$_};
    my $url = $h->{'address'};
    my $desc = $h->{'description'};
    my $id = $_;
    my $detecttime = $h->{'detecttime'};

    unless($full_load){
        next if(($detecttime cmp $goback) == -1);
    }
    
    my $domain;
    if($url =~ m/([a-z0-9-\.]+\.[a-z]{2,4})/){
        $domain = $1;
    }
    
    my $uuid = CIF::Message::UrlMalware->insert({
        address     => $url,
        impact      => 'malware url',
        source      => $partner,
        description => 'malware url '.$desc,
        severity    => 'medium',
        confidence  => 5,
        restriction => 'need-to-know',
        detecttime  => $detecttime,
        alternativeid  => 'http://www.malware.com.br/cgi/search.pl?id='.$id,
        alternativeid_restriction => 'public',
    });

    if($domain && $uuid =~ /^\d+$/){
        my $nsres = ($full_load) ? undef : Net::DNS::Resolver->new(nameservers => ['8.8.8.8','8.8.4.4'], recursive => 0);
        CIF::Message::DomainSimple->insert({
            relatedid   => $uuid->uuid(),
            nsres       => $nsres,
            address     => $domain,
            source      => $partner,
            description => 'malware domain '.$desc,
            impact      => 'malware domain',
            severity    => 'low',
            confidence  => 5,
            detecttime  => $detecttime,
        });
    }
    $uuid = ($uuid =~ /^\d+$/) ? $uuid->uuid() : $uuid;
    print $partner.' -- '.$url.' -- '.$detecttime.' -- '.$uuid."\n";
}
