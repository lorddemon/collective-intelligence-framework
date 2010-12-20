package CIF::WebAPI::infrastructure;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use CIF::WebAPI::infrastructure::address;
use CIF::Message::Structured;
use CIF::Message::InfrastructureSimple;
use Regexp::Common qw/net/;

sub submit {
    my ($self,%args) = @_;

    return CIF::Message::InfrastructureSimple->insert({
        source                      => $self->parent->source(),
        address                     => $args{'address'},
        confidence                  => $args{'confidence'},
        severity                    => $args{'severity'},
        impact                      => $args{'impact'},
        description                 => $args{'description'},
        detecttime                  => $args{'detecttime'},
        alternativeid               => $args{'alternativeid'},
        alternativeid_restriction   => $args{'alternativeid_restriction'},
        protocol                    => $args{'protocol'},
        portlist                    => $args{'portlist'},
    });
}

sub mapIndex {
    my $r = shift;
    my $idx = CIF::WebAPI::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
        address     => $r->address(),
        asn         => $r->asn(),
        asn_desc    => $r->asn_desc(),
        cidr        => $r->cidr(),
        cc          => $r->cc(),
        rir         => $r->rir(),
        portlist    => $r->portlist(),
        protocol    => $r->protocol(),
    };
} 

sub aggregateFeed {
    my @recs = @_;

    my @res = @{CIF::WebAPI::aggregateFeed('address',@recs)};
    my @feed = map { mapIndex($_->{'rec'}) } @res;
    return(@feed);
}

sub generateFeed {
    my $response = shift;
    my @recs = @_;

    my $start = time();
    my @feed = aggregateFeed(@recs);
    my $end = time();
    warn ($end - $start);
    $response->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

sub GET {
    my ($self, $request, $response) = @_;
    my @recs = $self->SUPER::GET($request,$response);
    return generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    if($frag =~ /^$RE{net}{IPv4}/){
        my $subh = CIF::WebAPI::infrastructure::address->new($self);
        $subh->{'address'} = $frag;
        return $subh;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
