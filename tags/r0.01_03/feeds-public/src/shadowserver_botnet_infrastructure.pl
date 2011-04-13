#!/usr/bin/perl -w

use strict;

use DateTime::Format::DateParse;
use DateTime;
use CIF::Message::InfrastructureSimple;
use Data::Dumper;
use Regexp::Common qw/net/;
use LWP::Simple;

my $source = 'shadowserver.org';
my $feed = 'http://www.shadowserver.org/ccfull.php';
my $sourceuuid = CIF::Message::genSourceUUID($source);

# load up the "last batch"
# need to see if anything fell off the list
# if so, we need to lower it's confidence

my $detecttime = DateTime->from_epoch(epoch => time());
$detecttime = $detecttime->ymd().'T00:00:00Z';

my $stale_recs;

my @recs = CIF::Message::InfrastructureSimple->search(source => $sourceuuid, severity => 'medium', confidence => 7, impact => 'botnet infrastructure');

foreach my $rec (@recs){
    $stale_recs->{$rec->address.$rec->portlist} = $rec;
}

my $text = get($feed) || die('unable to get feed: '.$!);
my @lines = split(/\n/,$text);

## 4.53.50.37:6667:webhose1.gamerdna.com:3356:US
## 8.7.233.36:6667:-:20473:US

foreach (@lines){
    next unless(/^($RE{net}{IPv4})\:(\d+)\:(\S+)\:(\d+)\:(\S+)$/);
    my ($address,$port,$domain,$asn,$cc) = ($1,$2,$3,$4,$5);
    $domain = undef if($domain eq '-');
    if(exists($stale_recs->{$address.$port})){
        delete($stale_recs->{$address.$port});
    }
   
    my $impact = 'botnet infrastructure';
    $impact .= ' '.$domain if($domain);
    my $description = $impact.' '.$address if($address);

    my $id = CIF::Message::InfrastructureSimple->insert({
        address => $address,
        impact  => $impact,
        source  => $source,
        description => $description,
        confidence  => 7,
        severity    => 'medium',
        detecttime  => $detecttime,
        portlist    => $port,
        restriction => 'need-to-know',
    });
    warn $id;
}

# re-insert everything that appears to have dropped off the list
# as low severity

my $time = DateTime->from_epoch(epoch => time());
foreach my $r (keys %$stale_recs){
    my $x = $stale_recs->{$r};
    my $id = CIF::Message::InfrastructureSimple->insert({
        address => $x->address(),
        asn     => $x->asn(),
        impact  => 'botnet infrastructure',
        source  => $source,
        description => $x->description(),
        confidence  => 9,
        severity    => 'low',
        portlist    => $x->portlist(),
        protocol    => $x->protocol,
        detecttime  => $time,
        restriction => 'need-to-know',
    });
    warn "$id re-inserted as low severity";
}
