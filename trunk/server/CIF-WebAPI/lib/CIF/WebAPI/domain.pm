package CIF::WebAPI::domain;
use base 'CIF::WebAPI';

use strict;
use warnings;

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(uc($frag) =~ /^[A-Z0-9.-]+\.[A-Z]{2,4}$/){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
