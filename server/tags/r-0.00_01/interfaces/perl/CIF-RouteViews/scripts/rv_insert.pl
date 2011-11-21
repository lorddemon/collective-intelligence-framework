#!/usr/bin/perl -w

package RV;
use base Class::DBI;

RV->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );
RV->table('rv');
RV->columns(All => qw/id sha1 asn asn_desc cc rir prefix cidr peer peer_desc detecttime created/);
1;

use strict;

use Digest::SHA1 qw(sha1_hex);
use Net::Abuse::Utils qw(:all);
my $x = 0;
while(<STDIN>){
    my $line = $_;
    my ($prefix,$peer,$asn) = split(/\s/,$line);

    my ($as,$cidr,$ccode,$rir,$date) = get_asn_info($prefix);
    next unless($as);
    my $asn_desc = get_as_description($as);
    my $peer_desc = get_as_description($peer);

    my $id = eval { 
        RV->insert({
            sha1    => sha1_hex($_),
            asn     => $asn,
            asn_desc    => $asn_desc,
            cc          => $ccode,
            rir         => $rir,
            prefix      => $prefix,
            cidr        => $cidr,
            peer        => $peer,
            peer_desc   => $peer_desc,
        })
    };
    if($@){
        die $@ unless($@ =~ /duplicate key value violates unique constraint/);
    }
    last if($x++ == 5000);
}
