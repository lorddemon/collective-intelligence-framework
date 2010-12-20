package CIF::WebAPI::domain;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Domain;
use CIF::WebAPI::domain::address;
use CIF::Message::DomainSimple;
use Net::DNS;
use JSON;

my $nsres = Net::DNS::Resolver->new(
    nameservers => ['8.8.8.8'],
);

sub submit {
    my ($self,%args) = @_;

    return CIF::Message::DomainSimple->insert({
        nsres                       => $nsres,
        source                      => $self->parent->source(), 
        address                     => $args{'address'},
        confidence                  => $args{'confidence'},
        severity                    => $args{'severity'},
        impact                      => $args{'impact'},
        description                 => $args{'description'},
        detecttime                  => $args{'detecttime'},
        alternativeid               => $args{'alternativeid'},
        alternativeid_restriction   => $args{'alternativeid_restriction'},
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
        ttl         => $r->ttl(),
        class       => $r->class(),
        rdata       => $r->rdata()
    };
}

sub aggregateFeed {
    my @recs = @_;

    my @res = @{CIF::WebAPI::aggregateFeed('address',@recs)};
    my @feed;
    foreach (@res){
        my $idx = mapIndex($_->{'rec'});
        delete($_->{'rec'});
        push(@feed,$idx);
    }
    return(@feed);
}

sub generateFeed {
    my $response = shift;
    my @recs = @_;

    my @feed = aggregateFeed(@recs);

    $response->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

sub GET {
    my ($self, $request, $response) = @_;
    my @recs = $self->SUPER::GET($request,$response);
    return generateFeed($response,@recs) if($#recs > -1);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(uc($frag) =~ /^[A-Z0-9.-]+\.[A-Z]{2,4}$/){
        my $subh;
        $subh = CIF::WebAPI::domain::address->new($self);
        $subh->{'address'} = $frag;
        return $subh;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
