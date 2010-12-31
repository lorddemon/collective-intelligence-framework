package CIF::WebAPI::infrastructure;
use base 'CIF::WebAPI';

use strict;
use warnings;

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

sub buildNext {
    my ($self,$frag,$req) = @_;

    if($frag =~ /^$RE{net}{IPv4}/){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
