package CIF::WebAPI::email;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::WebAPI::email::email;

sub buildNext {
    my ($self,$frag,$req) = @_;

    if(uc($frag) =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
