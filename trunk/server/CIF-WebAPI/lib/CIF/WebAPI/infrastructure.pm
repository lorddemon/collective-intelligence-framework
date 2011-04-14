package CIF::WebAPI::infrastructure;
use base 'CIF::WebAPI';

use strict;
use warnings;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub buildNext {
    my ($self,$frag,$req) = @_;

    if($req->uri() =~ /$RE{'net'}{'CIDR'}{'IPv4'}{-keep}/){
        if($2 < 8){
            $self->{'query'} = 'ERROR: cidr prefix must be larger than 7';
        } else {
            $self->{'query'} = $1.'/'.$2;
        }
        return $self;
    } elsif ($frag =~ /($RE{'net'}{'IPv4'})/) {
        $self->{'query'} = $1;
        return $self;
    } elsif(lc($frag) =~ /^(as\d+)$/) {
        $self->{'query'} = $1;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
