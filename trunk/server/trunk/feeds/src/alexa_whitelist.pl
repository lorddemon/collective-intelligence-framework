#!/usr/bin/perl -w

use CIF::Message::DomainWhitelist;
use DateTime;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use LWP::Simple;
use File::stat;

my $date = DateTime->from_epoch(epoch => time());
$date = $date->ymd().'T'.$date->hms().'Z';
my $limit = 400;

my $file = '/tmp/top-1m.csv.zip';
my $url = 'http://s3.amazonaws.com/alexa-static/top-1m.csv.zip';
my $delay = 24;

sub redownload_file {
    return 1 unless(-e $file && -s $file);
    my $st = stat($file) || die($!);
    return(1) if((time() - $st->ctime()) > (3600 * $delay));
    return (0);
}

my $content;
if(redownload_file()){
    warn 're-downloading file';
    $content = get($url);
    open(F,'>',$file);
    print F $content;
    close(F);
}

my $bucket = CIF::Message::DomainWhitelist->new();
$bucket->db_Main->{'AutoCommit'} = 0;

my $unzipped;
unzip $file => \$unzipped, Name => 'top-1m.csv' || die('unzip failed: '.$UnzipError);
my @lines = split(/\n/,$unzipped);

foreach (0 ... ($limit-1)){
    my $line = $lines[$_];
    my ($rank,$address) = split(/,/,$line);
    next unless($address =~ /ashampoo/);
    warn $address;
    my $id = CIF::Message::DomainWhitelist->insert({
        source     => 'alexa.com',
        impact      => 'domain whitelist',
        description => 'domain whitelist alexa.com #'.$rank.' '.$address,
        address     => $address,
        confidence  => 7,
        detecttime  => $date,
        restriction => 'need-to-know',
        alternativeid   => 'http://www.alexa.com/siteinfo/'.$address,
        alternativeid_restriction   => 'public',
    });
    warn $id;
}
$bucket->dbi_commit();
