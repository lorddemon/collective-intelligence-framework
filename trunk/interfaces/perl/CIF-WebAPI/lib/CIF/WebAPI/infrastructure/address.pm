package CIF::WebAPI::infrastructure::address;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Inet;
use Regexp::Common;
use Regexp::Common::net::CIDR;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->address();
    my @recs = CIF::Message::Inet->search_by_address($arg,5000);
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
