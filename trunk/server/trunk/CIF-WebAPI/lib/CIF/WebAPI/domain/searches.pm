package CIF::WebAPI::domain::searches;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainSearch;

sub GET {
    my ($self, $request, $response) = @_;

    if(exists($self->{'domain'})){
        my $arg = $self->domain();
        my @recs = CIF::Message::DomainSearch->search_by_address('%'.$arg.'%',10);
        if(@recs){
            my @res = map { CIF::WebAPI::domain::mapIndex($_) } @recs;
            $response->data()->{'result'} = \@res;
        }
    }
    return Apache2::Const::HTTP_OK;

}

sub buildNext {
    my ($self,$frag,$req) = @_;
    
    my $h = CIF::WebAPI::domain::searches->new($self);
    $h->{'domain'} = $frag;
    return $h;
}

1;
