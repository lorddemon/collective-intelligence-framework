#!/usr/bin/perl -w

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use Net::Abuse::Utils qw(:all);
use Regexp::Common qw/net/;
use DateTime::Format::DateParse;
use DateTime;
use Net::DNS;

use CIF::Message::DomainSimple;
use CIF::Message::InfrastructureSimple;

my $timeout = 5;
my $res = Net::DNS::Resolver->new(
    nameservers => ['8.8.8.8'],
);

my $partner = 'spyeyetracker.abuse.ch';
my $url = 'https://spyeyetracker.abuse.ch/monitor.php?rssfeed=tracker';
my $content;
my $rss = XML::RSS->new();

$content = get($url);
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    $_ = $item->{'description'};
    my ($host,$addr,$sbl,$status,$level) = m/^Host: (\S+), IP address:(\s\S+|\s), SBL: (\s*\S*)+, Status: (\S+), Level: (\d+)/;

    next unless($host && $status);
    for($level){
        $level = 'bulletproof hosted' if(/^1$/);
        $level = 'hacked webserver' if(/^2$/);
        $level = 'free hosting service' if(/^3$/);
        $level = 'unknown' if(/^4$/);
        $level = 'hosted on a fastflux botnet' if(/^5$/);
    }

    my $detecttime;
    if($item->{title} =~ /\((\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2})\)/){
        $detecttime = DateTime::Format::DateParse->parse_datetime($1);
    }
    $detecttime .= 'Z';

    my $uuid;
    if($host =~ /^$RE{net}{IPv4}$/){
        $uuid = CIF::Message::InfrastructureSimple->insert({
                source      => $partner,
                address     => $addr,
                impact      => 'spyeye botnet infrastructure',
                description => 'spyeye botnet infrastructure '.$level.' '.$addr,
                confidence  => 5,
                severity    => 'medium',
                reporrtime  => $detecttime,
                restriction => 'need-to-know',
                alternativeid => 'https://spyeyetracker.abuse.ch/monitor.php?host='.$addr,
                alternativeid_restriction => 'public',
        });
    } else {  
        my $impact = 'spyeye malware domain';
        $impact .= ' fastflux' if($level =~ /fastflux/);
        my $desc = $impact.' '.$level.' '.$host;
        $uuid = CIF::Message::DomainSimple->insert({
            nsres       => $res,
            address     => $host,
            source      => $partner,
            confidence  => 5,
            severity    => 'medium',
            impact      => $impact,
            description => $desc,
            detecttime  => $detecttime,
            alternativeid => 'https://spyeyetracker.abuse.ch/monitor.php?host='.$host,
            alternativeid_restriction => 'public',
            restriction => 'need-to-know',
        });
    }
    warn $uuid;
}
