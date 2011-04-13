package CIF::WebAPI::cc;
use base 'CIF::WebAPI';

use strict;
use warnings;

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(uc($frag) =~ /^[a-zA-Z]{2}$/){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
