package CIF::WebAPI::Plugin::email;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    my $self = shift;
    my $frag = shift;

    return unless(/^\w+@\w+/);
    return(1);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    if(uc($frag) =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/){
        $self->{'query'} = $frag;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
