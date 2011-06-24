package CIF::WebAPI::Plugin::infrastructure;
use base 'CIF::WebAPI::Plugin';

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub prepare {
    my $class = shift;
    my $frag = shift;

    return unless($frag =~ /^($RE{'net'}{'IPv4'})/);
    return(1);
}

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
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
