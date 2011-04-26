package CIF::WebAPI::Plugin::related;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    my $self = shift;
    my $frag = shift;

    return unless(isUUID(lc($frag)));
    return(1);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(isUUID(lc($frag))){
        $self->{'query'} = $1;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

sub isUUID {
    my $arg = shift;
    return undef unless($arg);
    return undef unless($arg =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    return(1);
}

1;
