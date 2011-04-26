package CIF::WebAPI::Plugin::asn;
use base 'CIF::WebAPI::Plugin';

sub prepare {
    my $self = shift;
    my $frag = shift;

    return unless(lc($frag) =~ /^as[0-9]*\.?[0-9]*$/);
    return(1);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    if(uc($frag) =~ /^AS([0-9]*\.?[0-9]*)$/){
        $self->{'query'} = $1;
        return $self;
    } else {
        return $self->SUPER::buildNext($frag,$req);
    }
}

1;
