#!/usr/bin/perl -w

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use DateTime;
use DateTime::Format::DateParse;
use MIME::Base64;
use CIF::Message::Malware;

my $partner = 'malwarepatrol.com.br';
my $url = 'http://www.malware.com.br/cgi/submit?action=list_hashes';

my $content = get($url) || die('unable to get feed: '.$!);

my @lines = split(/\n/,$content);
foreach (@lines){
    next if(/^(#|$)/);
    chomp();
    my ($description,$md5,$sha1) = split(/\t/,$_);
    my $id = encode_base64($description);
    my $severity = 'medium';

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00Z';

    my $uuid;
    my $impact = 'malware binary';
    if($md5){
        $uuid = CIF::Message::Malware->insert({
            source      => $partner,
            description => 'malware binary '.$description,
            impact      => $impact,
            hash_md5    => $md5,
            hash_sha1   => $sha1,
            restriction => 'need-to-know',
            detecttime  => $detecttime,
            confidence  => 7,
            severity    => $severity,
            alternativeid  => 'http://www.malware.com.br/cgi/search.pl?id='.$id,
            alternativeid_restriction => 'public',
        });
        $uuid = $uuid->uuid();
    }

    warn $uuid;

}
