#!/usr/bin/perl -w

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use MIME::Base64;
use CIF::Message::Malware;
use Getopt::Std;

my %opts;
getopts('d',\%opts);
my $debug = $opts{'d'};

my $partner = 'malwarepatrol.com.br';
my $url = 'http://www.malware.com.br/cgi/submit?action=list_hashes';

my $content = get($url) || die('unable to get feed: '.$!);
my $b = CIF::Message::Malware->new();
$b->db_Main->{'AutoCommit'} = 0 if($debug);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);
    chomp();
    my ($description,$md5,$sha1) = split(/\t/,$_);
    my $lid = encode_base64($description);
    my $severity = 'medium';

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';
    next unless($md5);

    my $impact = 'malware binary';
    my $id = $b->insert({
            source      => $partner,
            description => 'malware binary '.$description,
            impact      => $impact,
            hash_md5    => $md5,
            hash_sha1   => $sha1,
            restriction => 'need-to-know',
            detecttime  => $detecttime,
            confidence  => 7,
            severity    => $severity,
            alternativeid  => 'http://www.malware.com.br/cgi/search.pl?id='.$lid,
            alternativeid_restriction => 'public',
    });

    print $id.' -- '.$id->uuid().' -- '.$description."\n";
}
$b->dbi_commit() if($debug);
