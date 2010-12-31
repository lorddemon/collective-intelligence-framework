#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Std;
use DateTime;
use JSON;
use Digest::SHA1 qw/sha1_hex/;
use Digest::MD5 qw/md5_hex/;
use Encode qw/encode_utf8/;
use MIME::Base64;
use Config::Simple;
use Data::Dumper;
use Compress::Zlib;

my $cfg = $ENV{'HOME'}.'/.cif';
$cfg = Config::Simple->new($cfg) || die('missing config file');

my %opts;
getopts('d:f:s:r:m:',\%opts);

my %sev = (
    'high'      => 3,
    'medium'    => 2,
    'low'       => 1,
);

my $feed = $opts{'f'} || shift || 'infrastructure,infrastructure/botnet,infrastructure/malware,infrastructure/whitelist,domain/whitelist,domain,domain/malware,domain/botnet,domain/nameserver,domain/fastflux,malware,url,url/malware,url/botnet,url/phishing,email';
my $severity = $opts{'s'} || 'high';
my $restriction = $opts{'r'} || 'private';
my $maxdays     = $opts{'d'} || 30;
my $maxrecords  = $opts{'m'} || 10000;

my $restriction_map = $cfg->param(-block => 'restrictions');

my @feeds = split(/,/,$feed);
foreach (@feeds){
    warn 'processing: '.$_;
    my @bits    = split(/\//,$_);
    my $impact  = ucfirst($bits[$#bits]);
    my $type    = ucfirst($bits[$#bits-1]);
    $impact     = '' unless($#bits);
    my $description = $type;
    $description = $impact.' '.($type) unless($impact eq '');
    $description .= ' feed';

    my $bucket = 'CIF::Message::'.$type.$impact;
    eval "require $bucket";
    die($@) if($@);
    my $feed_bucket = 'CIF::Message::Feed'.$type.$impact;
    eval "require $feed_bucket";
    die($@) if($@);

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * $maxdays)));
    my @recs;
    if(lc($impact) =~ /whitelist/){
        @recs = $bucket->retrieve_from_sql(qq{
            detecttime >= '$detecttime'
            ORDER BY id DESC
            LIMIT $maxrecords
        });
    } else {
        @recs = $bucket->search_feed($detecttime,$maxrecords);
    }
    @recs = $feed_bucket->generate(@recs);
    my @res;
    foreach (@recs){
        push(@res,$_) if(lc($impact) eq 'search' || $sev{$_->{'severity'}} >= $sev{$severity});
    }
    @recs = @res;
    unless($#recs > -1){
        warn 'no records';
        exit();
    }
    if($restriction_map){
        foreach my $r (@recs){
            if(exists($restriction_map->{$r->{'restriction'}})){
                $r->{'restriction'} = $restriction_map->{$r->{'restriction'}};
            }
            if(exists($restriction_map->{$r->{'alternativeid_restriction'}})){
                $r->{'alternativeid_restriction'} = $restriction_map->{$r->{'alternativeid_restriction'}};
           }
        }
    }
    $impact = $type if($impact eq '');
    $severity = 'low' if(lc($impact) eq 'search');
    my $hash = {
        restriction => $restriction_map->{lc($restriction)},
        impact      => lc($impact),
        severity    => lc($severity),
        items       => \@recs
    };

    my $json = to_json($hash);
    my $zcontent = encode_base64(compress($json));

    my $id = $feed_bucket->insert({
        format      => 'application/json',
        source      => 'ren-isac.net',
        message     => $zcontent,
        hash_sha1   => sha1_hex($zcontent),
        severity    => $severity,
        description => lc($description),
        impact      => lc($impact),
        restriction => lc($restriction),
    });
    warn $id;
}
