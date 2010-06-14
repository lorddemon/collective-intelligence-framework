#!/usr/bin/perl -w

use strict;

use CIF::Message::Inet;
use Text::Table;
use Data::Dumper;

CIF::Message::Inet->set_sql('top_15' => qq{
    SELECT count(distinct(address)),cidr,impact,asn,asn_desc from inet
    where cidr is not null
    and reporttime >= '2010-06-01'
    group by cidr,impact,asn,asn_desc
    order by count desc limit 15
});

my $t = Text::Table->new(
    'count', { is_sep => 1, title => ' | ' },
    'cidr', { is_sep => 1, title => ' | ' },
    'impact', { is_sep => 1, title => ' | ' },
    'asn', { is_sep => 1, title => ' | ' },
    'asn_desc',
);

my @recs = CIF::Message::Inet->search_top_15();

foreach my $r (@recs) {
    $t->load([
        $r->{'count'},
        $r->cidr(),
        $r->impact(),
        $r->asn(),
        $r->asn_desc(),
    ]);
}

print $t;
