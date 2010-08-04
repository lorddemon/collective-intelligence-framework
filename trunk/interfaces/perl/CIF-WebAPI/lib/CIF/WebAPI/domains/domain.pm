package CIF::WebAPI::domains::domain;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Domain;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->domain();
    my @recs = CIF::Message::Domain->search_by_address('%'.$arg.'%',5000);
    unless(@recs){ return undef; }

    my @res = map { CIF::WebAPI::domains::mapIndex($_) } @recs;

    $response->data()->{'result'} = \@res;
    return Apache2::Const::HTTP_OK;
}

1;
