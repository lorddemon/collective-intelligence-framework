#!/usr/bin/perl -w

use strict;
use Error qw(:try);
use Data::Dumper;
use XML::IODEF;
use DateTime;
use DateTime::Format::DateParse;
use XML::LibXML;
use Net::Abuse::Utils qw(:all);

use CIF::Message::SuspiciousNetwork;

my $file = '/tmp/spamhaus_drop.txt';
my $site_ref = 'http://www.spamhaus.org/sbl/sbl.lasso?query=';
my $dt = DateTime->from_epoch(epoch => time());

#system('wget --quiet http://www.spamhaus.org/drop/drop.lasso -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^;/);
    next if($_ =~ /^\n/);
    my ($addr,$ref) = split(/ \; /,$_);
	$addr =~ s/(\n|\s+)//;
    $ref =~ s/\n$//;

    my $id = $ref;

    my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
    my $desc;
    $desc = get_as_description($as) if($as);

    $as         = undef if($as && $as eq 'NA');
    $network    = undef if($network && $network eq 'NA');
    $ccode      = undef if($ccode && $ccode eq 'NA');
    $rir        = undef if($rir && $rir eq 'NA');
    $date       = undef if($date && $date eq 'NA');
    $desc       = undef if($desc && $desc eq 'NA');

    my $detecttime = DateTime->from_epoch(epoch => time());
    $detecttime = $detecttime->ymd().'T00:00:00';

    warn CIF::Message::SuspiciousNetwork->insert({
        address     => $addr,
        source      => 'spamhaus.org',
        description => 'spamhaus sbl - '.$addr,
        impact      => 'suspicious network hijacked',
        confidence  => 7,
        severity    => 'high',
        sourceid     => $ref,
        asn         => $as,
        cidr        => $network,
        asn_desc    => $desc,
        cc          => $ccode,
        rir         => $rir,
        restriction => 'need-to-know',
        alternativeid  => $site_ref.$ref,
        alternativeid_restriction => 'public',
        detecttime  => $detecttime,
    });
#    last if $n++ == 2;
}
close(F);
