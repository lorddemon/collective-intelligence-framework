package CIF::WebAPI::domain::fastflux;
use base 'CIF::WebAPI';

use strict;
use warnings;

sub GET {
    my ($self, $request, $response) = @_;
    return CIF::WebAPI::domain::generateFeed($response,$self->SUPER::GET($request,$response));
}

1;
