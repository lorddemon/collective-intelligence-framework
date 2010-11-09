#!/usr/bin/perl -w

use strict;

use CIF::Message::InfrastructureNetwork;
use Data::Dumper;
use Text::Table;

CIF::Message::InfrastructureNetwork->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );

my $hash;
my @recs = CIF::Message::InfrastructureNetwork->retrieve_from_sql('detecttime >= \'2010-06-01 00:00:00Z\'');

foreach my $rec (@recs){
    next if(exists($hash->{$rec->address()}));
    $hash->{$rec->address()} = $rec;
    $hash->{$rec->address()}->{'asn'} = $rec->asn() || 0;
}

my $t = Text::Table->new(
    { title => '# ASN', align => 'left' }, { is_sep => 1, title => ' | ' }, 
    "ASN_DESC", { is_sep => 1, title => ' | ' },
    "CIDR", { is_sep => 1, title => ' | ' }, 
    "Address", { is_sep => 1, title => ' | ' }, 
    'Description', { is_sep => 1, title => ' | ' },
    'Country', { is_sep => 1, title => ' | ' },
    'Confidence', { is_sep => 1, title => ' | ' },
    'Severity', { is_sep => 1, title => ' | ' },
    'Restriction', { is_sep => 1, title => ' | ' },
    'uuid',
);

my @sort = sort { $hash->{$a}->{'asn'} <=> $hash->{$b}->{'asn'} } keys %$hash;

foreach my $h (@sort){
    my $r = $hash->{$h};
    my $asn = $r->asn() || 'NA';
    my $asn_desc = $r->asn_desc() || 'NA';
    my $cidr = $r->cidr() || 'NA';
    $t->load([
        $asn,
        $asn_desc,
        $cidr,
        $r->address(),
        $r->description(),
        $r->cc() || 'NA',
        $r->confidence(),
        $r->severity(),
        $r->restriction(),
        $r->uuid(),
    ]);
}

warn $t;
