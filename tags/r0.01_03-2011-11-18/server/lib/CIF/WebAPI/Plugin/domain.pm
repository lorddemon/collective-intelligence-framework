package CIF::WebAPI::Plugin::domain;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    my $self = shift;
    my $frag = shift;

    return unless($frag =~ /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/);
    return if($frag =~ /^\w+@\w+/);
    return(1);
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
