package CIF::WebAPI::domain;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainSimple;
use Net::DNS;

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
