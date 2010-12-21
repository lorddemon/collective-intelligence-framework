package CIF::Message::FeedInfrastructure;
use base 'CIF::Message::Feed';

use strict;
use warnings;

__PACKAGE__->table('feeds_infrastructure');

sub mapIndex {
    my $self = shift;
    my $r = shift;
    my $idx = $self->SUPER::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
        address     => $r->address(),
        asn         => $r->asn(),
        asn_desc    => $r->asn_desc(),
        cidr        => $r->cidr(),
        cc          => $r->cc(),
        rir         => $r->rir(),
        portlist    => $r->portlist(),
        protocol    => $r->protocol(),
    };
}

sub generate {
    my $self = shift;
    my @recs = @_;
    @recs = $self->SUPER::aggregateFeed('address',@recs);
    @recs = map { $self->mapIndex($_) } @recs;

    return(@recs);
}

1;
