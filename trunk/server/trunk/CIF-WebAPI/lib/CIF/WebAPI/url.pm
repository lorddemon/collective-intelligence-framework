package CIF::WebAPI::url;
use base 'CIF::WebAPI';

use strict;
use warnings;

sub buildNext {
    my ($self,$frag,$req) = @_;    

    if(lc($frag) =~ /^([a-f0-9]{32})|([a-f0-9]{40})$/){
        $self->{'query'} = $frag;
        return $self;
    }
    return $self->SUPER::buildNext($frag,$req);
}

1;
