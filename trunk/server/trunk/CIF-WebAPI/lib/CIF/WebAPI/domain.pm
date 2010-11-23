package CIF::WebAPI::domains;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Domain;
use CIF::WebAPI::domains::domain;
use CIF::WebAPI::domains::nameservers;
use CIF::WebAPI::domains::malware;
use CIF::WebAPI::domains::fastflux;
use CIF::WebAPI::domains::cache;
use CIF::WebAPI::domains::searches;
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

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my @recs = CIF::Message::Domain->search_feed($detecttime,10000);
    return generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    for(lc($frag)){
        if(/^(nameservers|malware|fastflux|cache|searches)$/){
            my $mod = "CIF::WebAPI::domains::$frag";
            return $mod->new($self);
            last;
        }
        $subh = CIF::WebAPI::domains::domain->new($self);
        $subh->{'domain'} = $frag;
        return $subh;
    }
}

1;
