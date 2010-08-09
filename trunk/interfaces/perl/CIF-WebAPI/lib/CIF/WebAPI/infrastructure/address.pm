package CIF::WebAPI::infrastructure::address;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use Regexp::Common;
use Regexp::Common::net::CIDR;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->address();
    return Apache2::Const::HTTP_BAD_REQUEST unless($arg =~ /^$RE{net}{IPv4}/);
    my @recs = CIF::Message::Infrastructure->search_by_address($arg,5000);
    unless(@recs){ return undef; }

    my @res = map { CIF::WebAPI::infrastructure::mapIndex($_) } @recs;
    
    $response->data()->{'result'} = \@res;
    return Apache2::Const::HTTP_OK;
}

sub buildNext {
    my ($self,$frag,$req,$resp) = @_;

    if($req->uri() =~ /($RE{net}{CIDR}{IPv4})$/){
        my $subh = CIF::WebAPI::infrastructure::address->new($self);
        $subh->{'address'} = $1;
        return $subh;
    }
}

1;
