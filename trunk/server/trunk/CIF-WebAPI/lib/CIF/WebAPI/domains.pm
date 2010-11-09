package CIF::WebAPI::domains;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Domain;
use CIF::WebAPI::domains::domain;
use CIF::WebAPI::domains::nameservers;
use CIF::Message::DomainSimple;
use Net::DNS;
use JSON;

my $nsres = Net::DNS::Resolver->new(
    nameservers => ['8.8.8.8'],
);

sub isAuth {
    my ($self,$method,$req) = @_;
    return ($method eq 'GET' || $method eq 'POST');
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

sub POST {
    my ($self, $req, $resp) = @_;
    my $json;
    $req->read($json,$req->headers_in->{'Content-Length'});

    my @array = @{from_json($json)}; # or return invaild
    warn $self->{'userid'};
    use Data::Dumper;
    warn Dumper($self);

    my @ids;
    foreach (@array){
        my ($address,$impact,$confidence,$severity,$description,$detecttime,$restriction) = (
            $_->{'address'},
            $_->{'impact'} || 'suspicious domain',
            $_->{'confidence'} || 5,
            $_->{'severity'} || 'medium',
            $_->{'description'}, 
            $_->{'detecttime'},
            $_->{'restriction'} || 'private',
        );

        unless($address && $description && $detecttime){
            return Apache2::Const::SERVER_ERROR;
        }

        $severity = ($severity eq 'low') ? 'low' : 'medium';
        my $source = 'example.com';
    
        my $id = submit(
            address                     => $address,
            source                      => 'example.com',
            confidence                  => $confidence,
            severity                    => $severity,
            impact                      => $impact,
            description                 => $description,
            detecttime                  => $detecttime,
            restriction                 => $restriction,
        );
        push(@ids,$id->uuid->id());
    }
    $resp->data()->{'result'} = \@ids;
    return Apache2::Const::HTTP_OK;
}

sub submit {
    my %args = @_;

    my $uuid = CIF::Message::DomainSimple->insert({
        nsres                       => $nsres,
        source                      => $args{'source'},
        address                     => $args{'address'},
        confidence                  => $args{'confidence'},
        severity                    => $args{'severity'},
        impact                      => $args{'impact'},
        description                 => $args{'description'},
        detecttime                  => $args{'detecttime'},
        alternativeid               => $args{'alternativeid'},
        alternativeid_restriction   => $args{'alternativeid_restriction'},
        restriction                 => $args{'restriction'},
    });
    return $uuid;
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    for(lc($frag)){
        if(/^nameservers$/){
            $subh = CIF::WebAPI::domains::nameservers->new($self);
            return $subh;
            last;
        }
        $subh = CIF::WebAPI::domains::domain->new($self);
        $subh->{'domain'} = $frag;
        return $subh;
    }
}

1;
