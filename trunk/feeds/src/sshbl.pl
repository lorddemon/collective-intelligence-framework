#!/usr/bin/perl -w

use strict;
use CIF::Message::InfrastructureSimple;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use Regexp::Common qw/net/;

my $feed = 'http://www.sshbl.org/lists/date.txt';

my $content = get($feed);
my @lines = split(/\n/,$content);

foreach (@lines){
    next if(/^#/);
    my ($ip,$date) = m/^(\S+)[\s]+(\d+)$/;

    $date = DateTime->from_epoch(epoch => $date);
    warn CIF::Message::InfrastructureSimple->insert({
        address                     => $ip,
        source                      => 'sshbl.org',
        description                 => 'ssh scanner '.$ip,
        impact                      => 'ssh scanner',
        confidence                  => 5,
        portlist                    => 22,
        protocol                    => 6,
        severity                    => 'medium',
        restriction                 => 'need-to-know',
        alternativeid               => $feed,
        alternativeid_restriction   => 'public',
        detecttime                  => $date,
    });
}
