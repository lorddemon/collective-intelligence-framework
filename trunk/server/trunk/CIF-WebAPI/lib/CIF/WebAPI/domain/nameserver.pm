package CIF::WebAPI::domain::nameservers;
use base 'CIF::WebAPI';

use strict;
use warnings;

sub GET {
    my ($self, $request, $response) = @_;
    return CIF::WebAPI::domains::generateFeed($response,$self->SUPER::GET($request,$response));
}

1;
